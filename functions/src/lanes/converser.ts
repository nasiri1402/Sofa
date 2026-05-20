import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getApps, initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {defineSecret} from "firebase-functions/params";

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");
const OPENAI_BASE_URL = "https://api.openai.com/v1";

type ConverserPayload = {
  conversation_id?: string;
};

type OpenAIRequestDescriptor = {
  method: string;
  path: string;
  body?: unknown;
};

/**
 * Returns the Firestore user document reference for the given uid.
 * @param {string} uid
 * @return {FirebaseFirestore.DocumentReference}
 */
function userDocument(uid: string) {
  return db.collection("users").doc(uid);
}

/**
 * Returns the request log collection used by the conversation manager.
 * @param {string} uid
 * @return {FirebaseFirestore.CollectionReference}
 */
function converserRequestCollection(uid: string) {
  return userDocument(uid)
    .collection("assistants")
    .doc("converser")
    .collection("requests");
}

/**
 * Writes a conversation log entry without failing the main function flow.
 * @param {Promise<unknown>} operation
 * @param {string} stage
 * @return {Promise<void>}
 */
async function logSafely(operation: Promise<unknown>, stage: string) {
  try {
    await operation;
  } catch (error) {
    console.error("Converser logging failed", {stage, error});
  }
}

/**
 * Calls the OpenAI API and returns the parsed JSON body.
 * @param {string} path
 * @param {RequestInit | undefined} init
 * @return {Promise<unknown>}
 */
async function openAIRequest(
  path: string,
  init?: RequestInit,
): Promise<unknown> {
  const response = await fetch(`${OPENAI_BASE_URL}${path}`, {
    ...init,
    headers: {
      "Authorization": `Bearer ${OPENAI_API_KEY.value()}`,
      "Content-Type": "application/json",
      ...(init?.headers ?? {}),
    },
  });

  const raw = await response.text();
  let parsedRaw: unknown = raw;
  try {
    parsedRaw = JSON.parse(raw);
  } catch {
    parsedRaw = {raw};
  }

  if (!response.ok) {
    console.error("OpenAI converser error", {
      path,
      status: response.status,
      statusText: response.statusText,
      requestId: response.headers.get("x-request-id") ?? undefined,
      body: parsedRaw,
    });
    throw new HttpsError(
      "unknown",
      "The service is temporarily unavailable.\nPlease try again shortly.",
    );
  }

  return parsedRaw;
}

/**
 * Handles create conversation action.
 * @param {FirebaseFirestore.DocumentReference} requestLogRef
 * @param {string} action
 * @return {Promise<{action: string, payload: {conversation_id: string}}>}
 */
async function handleCreateThread(
  requestLogRef: FirebaseFirestore.DocumentReference,
  action: string,
) {
  const requestJSON: OpenAIRequestDescriptor = {
    method: "POST",
    path: "/conversations",
    body: {},
  };

  const response = await openAIRequest(requestJSON.path, {
    method: "POST",
    body: JSON.stringify(requestJSON.body),
  }) as {id?: string};

  if (!response.id) {
    throw new HttpsError("unknown", "OpenAI conversation ID is missing.");
  }

  await logSafely(
    requestLogRef.set(
      {
        action,
        status: "success",
        conversation_id: response.id,
        request_json: requestJSON,
        response_json: response,
        updated_at: FieldValue.serverTimestamp(),
        finished_at: FieldValue.serverTimestamp(),
      },
      {merge: true},
    ),
    "converser_create_success",
  );

  return {
    action: "create",
    payload: {
      conversation_id: response.id,
    },
  };
}

/**
 * Handles close conversation action.
 * @param {FirebaseFirestore.DocumentReference} requestLogRef
 * @param {string} action
 * @param {string} conversationID
 * @return {Promise<{action: string, payload: {deleted: boolean}}>}
 */
async function handleCloseThread(
  requestLogRef: FirebaseFirestore.DocumentReference,
  action: string,
  conversationID: string,
) {
  if (!conversationID) {
    throw new HttpsError(
      "invalid-argument",
      "Missing 'payload.conversation_id'.",
    );
  }

  const requestJSON: OpenAIRequestDescriptor = {
    method: "DELETE",
    path: `/conversations/${conversationID}`,
  };

  const response = await openAIRequest(requestJSON.path, {
    method: "DELETE",
  }) as {deleted?: boolean};

  await logSafely(
    requestLogRef.set(
      {
        action,
        status: "success",
        conversation_id: conversationID,
        request_json: requestJSON,
        response_json: response,
        updated_at: FieldValue.serverTimestamp(),
        finished_at: FieldValue.serverTimestamp(),
      },
      {merge: true},
    ),
    "converser_close_success",
  );

  return {
    action: "close",
    payload: {
      deleted: response.deleted ?? true,
    },
  };
}

/**
 * Creates a new conversation for the authenticated user.
 */
export const converser = onCall(
  {
    region: "us-central1",
    secrets: [OPENAI_API_KEY],
    enforceAppCheck: true,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Auth required.");
    }

    const action = typeof request.data?.action === "string" ?
      request.data.action.trim() :
      "";
    const payload = (request.data?.payload ?? {}) as ConverserPayload;
    const conversationID = typeof payload.conversation_id === "string" ?
      payload.conversation_id.trim() :
      "";

    if (!action) {
      throw new HttpsError("invalid-argument", "Missing 'action'.");
    }

    const requestLogRef = converserRequestCollection(uid).doc();
    const now = FieldValue.serverTimestamp();
    const requestJSON: OpenAIRequestDescriptor =
      action === "create" ?
        {
          method: "POST",
          path: "/conversations",
          body: {},
        } :
        {
          method: "DELETE",
          path: `/conversations/${conversationID}`,
        };

    await logSafely(
      Promise.all([
        userDocument(uid).set(
          {uid, updated_at: now},
          {merge: true},
        ),
        requestLogRef.set(
          {
            action,
            status: "started",
            created_at: now,
            updated_at: now,
            request_json: requestJSON,
          },
          {merge: true},
        ),
      ]),
      "converser_started",
    );

    try {
      switch (action) {
      case "create":
        return handleCreateThread(requestLogRef, action);
      case "close":
        return handleCloseThread(requestLogRef, action, conversationID);
      default:
        throw new HttpsError(
          "invalid-argument",
          `Unsupported action '${action}'.`,
        );
      }
    } catch (error) {
      await logSafely(
        requestLogRef.set(
          {
            action,
            status: "error",
            request_json: requestJSON,
            error_json: {
              message: error instanceof Error ? error.message : String(error),
            },
            updated_at: FieldValue.serverTimestamp(),
            finished_at: FieldValue.serverTimestamp(),
          },
          {merge: true},
        ),
        "converser_error",
      );
      throw error;
    }
  },
);
