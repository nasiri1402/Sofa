import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getApps, initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {defineSecret} from "firebase-functions/params";

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

/**
 * Returns the Firestore user document reference for the given uid.
 * @param {string} uid
 * @return {FirebaseFirestore.DocumentReference}
 */
function userDocument(uid: string) {
  return db.collection("users").doc(uid);
}

/**
 * Returns the request log collection used by the generator assistant.
 * @param {string} uid
 * @return {FirebaseFirestore.CollectionReference}
 */
function generatorRequestCollection(uid: string) {
  return userDocument(uid)
    .collection("assistants")
    .doc("generator")
    .collection("requests");
}

/**
 * Writes a generator log entry without failing the main function flow.
 * @param {Promise<unknown>} operation
 * @param {string} stage
 * @return {Promise<void>}
 */
async function logSafely(operation: Promise<unknown>, stage: string) {
  try {
    await operation;
  } catch (error) {
    console.error("Generator logging failed", {stage, error});
  }
}

/**
 * Generates a structured project plan with the OpenAI Responses API.
 */
export const generator = onCall(
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
    const {
      messages,
      response_format: responseFormat,
    } = request.data ?? {};

    if (!Array.isArray(messages) || messages.length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "Missing or empty 'messages' array",
      );
    }

    if (!responseFormat) {
      throw new HttpsError("invalid-argument", "Missing 'response_format'");
    }

    // Сборка тела запроса (без логирования)
    const body = {
      model: "gpt-5-nano",
      input: messages,
      max_output_tokens: 10000,
      reasoning: {effort: "low"},
      text: {format: responseFormat},
    };

    const requestLogRef = generatorRequestCollection(uid).doc();
    const requestStartedAt = FieldValue.serverTimestamp();

    await logSafely(
      Promise.all([
        userDocument(uid).set(
          {
            uid,
            updated_at: requestStartedAt,
          },
          {merge: true},
        ),
        requestLogRef.set(
          {
            status: "started",
            request_json: body,
            created_at: requestStartedAt,
            updated_at: requestStartedAt,
          },
          {merge: true},
        ),
      ]),
      "started",
    );

    const resp = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${OPENAI_API_KEY.value()}`,
      },
      body: JSON.stringify(body),
    });

    const raw = await resp.text();
    const requestId = resp.headers.get("x-request-id") ?? undefined;

    let parsedRaw: unknown = raw;
    try {
      parsedRaw = JSON.parse(raw);
    } catch {
      parsedRaw = {raw};
    }

    if (!resp.ok) {
      console.error("OpenAI error", {
        uid,
        status: resp.status,
        statusText: resp.statusText,
        requestId,
      });

      await logSafely(
        requestLogRef.set(
          {
            status: "error",
            response_json: parsedRaw,
            error_json: {
              status: resp.status,
              status_text: resp.statusText,
              request_id: requestId ?? null,
              body: parsedRaw,
            },
            updated_at: FieldValue.serverTimestamp(),
            finished_at: FieldValue.serverTimestamp(),
          },
          {merge: true},
        ),
        "error",
      );

      throw new HttpsError(
        "unknown",
        "The service is temporarily unavailable.\nPlease try again shortly.",
      );
    }

    const data = parsedRaw as Record<string, unknown>;
    await logSafely(
      requestLogRef.set(
        {
          status: "success",
          model: data?.model ?? body.model,
          response_json: data,
          updated_at: FieldValue.serverTimestamp(),
          finished_at: FieldValue.serverTimestamp(),
        },
        {merge: true},
      ),
      "success",
    );

    return data;
  },
);
