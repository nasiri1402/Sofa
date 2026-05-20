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
const OPENAI_CHAT_MODEL = "gpt-5-nano";
const CONVERSATION_CONTEXT_PREFIX = "CONVERSATION CONTEXT";
const MESSAGE_CONTEXT_PREFIX = "MESSAGE CONTEXT";

type ChatterPayload = {
  conversation_id?: string;
  message?: string;
  context?: string;
};

type OpenAIResponse = {
  output?: OpenAIResponseOutputItem[];
};

type OpenAIResponseOutputItem = {
  type?: string;
  role?: string;
  content?: OpenAIResponseContentPart[];
};

type OpenAIResponseContentPart = {
  type?: string;
  text?: string;
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
 * Returns the request log collection used by the chat assistant.
 * @param {string} uid
 * @return {FirebaseFirestore.CollectionReference}
 */
function chatterRequestCollection(uid: string) {
  return userDocument(uid)
    .collection("assistants")
    .doc("chatter")
    .collection("requests");
}

/**
 * Writes a chat log entry without failing the main function flow.
 * @param {Promise<unknown>} operation
 * @param {string} stage
 * @return {Promise<void>}
 */
async function logSafely(operation: Promise<unknown>, stage: string) {
  try {
    await operation;
  } catch (error) {
    console.error("Chatter logging failed", {stage, error});
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
    console.error("OpenAI chatter error", {
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
 * Extracts text content from a response output.
 * @param {OpenAIResponse | undefined} response
 * @return {string}
 */
function responseOutputText(response?: OpenAIResponse): string {
  const output = response?.output ?? [];
  return output
    .filter((item) => item.type === "message" && item.role === "assistant")
    .flatMap((item) => item.content ?? [])
    .filter((part) => part.type === "output_text")
    .map((part) => part.text?.trim() ?? "")
    .filter(Boolean)
    .join("\n\n")
    .trim();
}

/**
 * Formats a conversation context block
 * that should live in conversation history.
 * @param {string} context
 * @return {string}
 */
function makeThreadContextMessage(context: string): string {
  return `${CONVERSATION_CONTEXT_PREFIX}\n${context}`.trim();
}

/**
 * Formats a user message with optional message-level context.
 * @param {string} message
 * @param {string} context
 * @return {string}
 */
function makeUserMessage(message: string, context: string): string {
  if (!context) {
    return message;
  }

  return [
    MESSAGE_CONTEXT_PREFIX,
    context,
    "",
    "USER MESSAGE",
    message,
  ].join("\n").trim();
}

/**
 * Handles chat context update action.
 * @param {FirebaseFirestore.DocumentReference} requestLogRef
 * @param {string} action
 * @param {string} conversationID
 * @param {string} context
 * @return {Promise<{action: string, payload: {updated: boolean}}>}
 */
async function handleUpdateContext(
  requestLogRef: FirebaseFirestore.DocumentReference,
  action: string,
  conversationID: string,
  context: string,
) {
  if (!context) {
    throw new HttpsError("invalid-argument", "Missing 'payload.context'.");
  }

  const requestJSON: OpenAIRequestDescriptor = {
    method: "POST",
    path: `/conversations/${conversationID}/items`,
    body: {
      items: [{
        type: "message",
        role: "user",
        content: makeThreadContextMessage(context),
      }],
    },
  };

  const response = await openAIRequest(requestJSON.path, {
    method: "POST",
    body: JSON.stringify(requestJSON.body),
  });

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
    "update_context_success",
  );

  return {
    action: "update_context",
    payload: {
      updated: true,
    },
  };
}

/**
 * Handles send message action.
 * @param {FirebaseFirestore.DocumentReference} requestLogRef
 * @param {string} action
 * @param {string} conversationID
 * @param {string} message
 * @param {string} context
 * @return {Promise<{action: string, payload: {message: string}}>}
 */
async function handleSendMessage(
  requestLogRef: FirebaseFirestore.DocumentReference,
  action: string,
  conversationID: string,
  message: string,
  context: string,
) {
  if (!message) {
    throw new HttpsError("invalid-argument", "Missing 'payload.message'.");
  }

  const requestJSON: OpenAIRequestDescriptor = {
    method: "POST",
    path: "/responses",
    body: {
      model: OPENAI_CHAT_MODEL,
      conversation: conversationID,
      instructions: [
        "When replying, search this conversation for the most recent " +
          "message that starts with \"" +
          CONVERSATION_CONTEXT_PREFIX +
          "\".",
        "Treat that message as the current source of truth for the plan.",
      ].join("\n"),
      input: [{
        type: "message",
        role: "user",
        content: makeUserMessage(message, context),
      }],
    },
  };

  const response = await openAIRequest(requestJSON.path, {
    method: "POST",
    body: JSON.stringify(requestJSON.body),
  }) as OpenAIResponse;

  const assistantMessage = responseOutputText(response);
  if (!assistantMessage) {
    throw new HttpsError("unknown", "Assistant response was empty.");
  }

  await logSafely(
    requestLogRef.set(
      {
        action,
        status: "success",
        model: OPENAI_CHAT_MODEL,
        conversation_id: conversationID,
        request_json: requestJSON,
        response_json: response,
        updated_at: FieldValue.serverTimestamp(),
        finished_at: FieldValue.serverTimestamp(),
      },
      {merge: true},
    ),
    "send_message_success",
  );

  return {
    action: "send_message",
    payload: {
      message: assistantMessage,
    },
  };
}

/**
 * Sends a message to an existing conversation and returns the assistant reply.
 */
export const chatter = onCall(
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
    const payload = (request.data?.payload ?? {}) as ChatterPayload;
    const conversationID = typeof payload.conversation_id === "string" ?
      payload.conversation_id.trim() :
      "";
    const message = typeof payload.message === "string" ?
      payload.message.trim() :
      "";
    const context = typeof payload.context === "string" ?
      payload.context.trim() :
      "";

    if (!action) {
      throw new HttpsError("invalid-argument", "Missing 'action'.");
    }

    if (!conversationID) {
      throw new HttpsError(
        "invalid-argument",
        "Missing 'payload.conversation_id'.",
      );
    }

    const requestLogRef = chatterRequestCollection(uid).doc();
    const now = FieldValue.serverTimestamp();
    const requestJSON: OpenAIRequestDescriptor =
      action === "update_context" ?
        {
          method: "POST",
          path: `/conversations/${conversationID}/items`,
          body: {
            items: [{
              type: "message",
              role: "user",
              content: makeThreadContextMessage(context),
            }],
          },
        } :
        {
          method: "POST",
          path: "/responses",
          body: {
            model: OPENAI_CHAT_MODEL,
            conversation: conversationID,
            instructions: [
              "When replying, search this conversation for the most " +
                "recent message that starts with \"" +
                CONVERSATION_CONTEXT_PREFIX +
                "\".",
              "Treat that message as the current source of truth for the plan.",
            ].join("\n"),
            input: [{
              type: "message",
              role: "user",
              content: makeUserMessage(message, context),
            }],
          },
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
            conversation_id: conversationID,
            request_json: requestJSON,
            created_at: now,
            updated_at: now,
          },
          {merge: true},
        ),
      ]),
      "chatter_started",
    );

    try {
      switch (action) {
      case "update_context":
        return handleUpdateContext(
          requestLogRef,
          action,
          conversationID,
          context,
        );
      case "send_message":
        return handleSendMessage(
          requestLogRef,
          action,
          conversationID,
          message,
          context,
        );
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
            conversation_id: conversationID,
            request_json: requestJSON,
            error_json: {
              message: error instanceof Error ? error.message : String(error),
            },
            updated_at: FieldValue.serverTimestamp(),
            finished_at: FieldValue.serverTimestamp(),
          },
          {merge: true},
        ),
        "chatter_error",
      );
      throw error;
    }
  },
);
