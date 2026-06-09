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

type ChatterPayload = {
  conversation_id?: string;
  message?: string;
  context?: string;
  instructions?: string;
  item_id?: string;
};

type OpenAIResponse = {
  output?: OpenAIResponseOutputItem[];
};

type OpenAIResponseOutputItem = {
  id?: string;
  type?: string;
  role?: string;
  content?: OpenAIResponseContentPart[];
};

type OpenAIResponseContentPart = {
  type?: string;
  text?: string;
};

type OpenAIConversationItem = {
  id?: string;
  type?: string;
  role?: string;
  content?: OpenAIConversationContentPart[] | string;
};

type OpenAIConversationContentPart = {
  type?: string;
  text?: string;
};

type OpenAIConversationItemsResponse = {
  data?: OpenAIConversationItem[];
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
 * Returns conversation items from a list response.
 * @param {unknown} response
 * @return {OpenAIConversationItem[]}
 */
function conversationItems(response: unknown): OpenAIConversationItem[] {
  if (Array.isArray(response)) {
    return response as OpenAIConversationItem[];
  }
  if (
    response &&
    typeof response === "object" &&
    "data" in response &&
    Array.isArray((response as OpenAIConversationItemsResponse).data)
  ) {
    return (response as OpenAIConversationItemsResponse).data ?? [];
  }
  return [];
}

/**
 * Extracts text content from a conversation item.
 * @param {OpenAIConversationItem} item
 * @return {string}
 */
function conversationItemText(item: OpenAIConversationItem): string {
  if (typeof item.content === "string") {
    return item.content.trim();
  }
  const content = Array.isArray(item.content) ? item.content : [];
  return content
    .map((part) => part.text?.trim() ?? "")
    .filter(Boolean)
    .join("\n\n")
    .trim();
}

/**
 * Lists conversation items for the given conversation id.
 * @param {string} conversationID
 * @return {Promise<OpenAIConversationItem[]>}
 */
async function listConversationItems(
  conversationID: string,
): Promise<OpenAIConversationItem[]> {
  const response = await openAIRequest(
    `/conversations/${conversationID}/items`,
    {
      method: "GET",
    },
  );
  return conversationItems(response);
}

/**
 * Returns the id of the last conversation item matching the predicate.
 * @param {OpenAIConversationItem[]} items
 * @param {Function} predicate
 * @return {string | null}
 */
function lastMatchingConversationItemID(
  items: OpenAIConversationItem[],
  predicate: (item: OpenAIConversationItem) => boolean,
): string | null {
  for (let index = items.length - 1; index >= 0; index -= 1) {
    const item = items[index];
    if (item?.id && predicate(item)) {
      return item.id;
    }
  }
  return null;
}

/**
 * Returns the conversation context block
 * as it should be stored in conversation history.
 * @param {string} context
 * @return {string}
 */
function makeThreadContextMessage(context: string): string {
  return context.trim();
}

/**
 * Formats the current request as JSON for the model input.
 * @param {string} message
 * @param {string} context
 * @return {string}
 */
function makeUserMessage(message: string, context: string): string {
  const payload = context ?
    {message, context} :
    {message};
  return JSON.stringify(payload, null, 2);
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
 * Handles delete message action.
 * @param {FirebaseFirestore.DocumentReference} requestLogRef
 * @param {string} action
 * @param {string} conversationID
 * @param {string} itemID
 * @return {Promise<{action: string, payload: {deleted: boolean}}>}
 */
async function handleDeleteItem(
  requestLogRef: FirebaseFirestore.DocumentReference,
  action: string,
  conversationID: string,
  itemID: string,
) {
  if (!itemID) {
    throw new HttpsError("invalid-argument", "Missing 'payload.item_id'.");
  }

  const requestJSON: OpenAIRequestDescriptor = {
    method: "DELETE",
    path: `/conversations/${conversationID}/items/${itemID}`,
  };

  const response = await openAIRequest(requestJSON.path, {
    method: "DELETE",
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
    "delete_message_success",
  );

  return {
    action: "delete_message",
    payload: {
      deleted: true,
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
 * @param {string} instructions
 * @return {Promise<{action: string, payload: {message: string}}>}
 */
async function handleSendMessage(
  requestLogRef: FirebaseFirestore.DocumentReference,
  action: string,
  conversationID: string,
  message: string,
  context: string,
  instructions: string,
) {
  if (!message) {
    throw new HttpsError("invalid-argument", "Missing 'payload.message'.");
  }

  const inputJSON = makeUserMessage(message, context);
  const itemsBefore = await listConversationItems(conversationID);
  const itemIDsBefore = new Set(
    itemsBefore.map((item) => item.id).filter(Boolean),
  );

  const requestJSON: OpenAIRequestDescriptor = {
    method: "POST",
    path: "/responses",
    body: {
      model: OPENAI_CHAT_MODEL,
      conversation: conversationID,
      instructions,
      input: [{
        type: "message",
        role: "user",
        content: inputJSON,
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
  const itemsAfter = await listConversationItems(conversationID);
  const addedItems = itemsAfter.filter(
    (item) => item.id && !itemIDsBefore.has(item.id),
  );
  const userItemID = lastMatchingConversationItemID(
    addedItems,
    (item) =>
      item.type === "message" &&
      item.role === "user" &&
      conversationItemText(item) === inputJSON,
  );
  const assistantItemID =
    response.output
      ?.find((item) => item.type === "message" && item.role === "assistant")
      ?.id ??
    lastMatchingConversationItemID(
      addedItems,
      (item) =>
        item.type === "message" &&
        item.role === "assistant" &&
        conversationItemText(item) === assistantMessage,
    ) ??
    null;

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
      user_item_id: userItemID,
      assistant_item_id: assistantItemID,
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
    const itemID = typeof payload.item_id === "string" ?
      payload.item_id.trim() :
      "";
    const instructions = typeof payload.instructions === "string" ?
      payload.instructions.trim() :
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

    let requestJSON: OpenAIRequestDescriptor;
    if (action === "update_context") {
      requestJSON = {
        method: "POST",
        path: `/conversations/${conversationID}/items`,
        body: {
          items: [
            {
              type: "message",
              role: "user",
              content: makeThreadContextMessage(context),
            },
          ],
        },
      };
    } else if (action === "delete_message") {
      requestJSON = {
        method: "DELETE",
        path: `/conversations/${conversationID}/items/${itemID}`,
      };
    } else {
      requestJSON = {
        method: "POST",
        path: "/responses",
        body: {
          model: OPENAI_CHAT_MODEL,
          conversation: conversationID,
          instructions,
          input: [
            {
              type: "message",
              role: "user",
              content: makeUserMessage(message, context),
            },
          ],
        },
      };
    }

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
      case "delete_message":
        return handleDeleteItem(
          requestLogRef,
          action,
          conversationID,
          itemID,
        );
      case "send_message":
        return handleSendMessage(
          requestLogRef,
          action,
          conversationID,
          message,
          context,
          instructions,
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
