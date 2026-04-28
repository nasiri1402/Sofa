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
 * Generates a structured project plan with the OpenAI Responses API.
 */
export const generator = onCall(
  {
    region: "us-central1",
    secrets: [OPENAI_API_KEY],
    enforceAppCheck: false,
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

    await Promise.all([
      userDocument(uid).set(
        {
          uid,
          updatedAt: requestStartedAt,
        },
        {merge: true},
      ),
      requestLogRef.set(
        {
          status: "started",
          requestJson: body,
          createdAt: requestStartedAt,
          updatedAt: requestStartedAt,
        },
        {merge: true},
      ),
    ]);

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

      await requestLogRef.set(
        {
          status: "error",
          responseJson: parsedRaw,
          errorJson: {
            status: resp.status,
            statusText: resp.statusText,
            requestId: requestId ?? null,
            body: parsedRaw,
          },
          updatedAt: FieldValue.serverTimestamp(),
          finishedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
      );

      throw new HttpsError(
        "unknown",
        "The service is temporarily unavailable.\nPlease try again shortly.",
      );
    }

    const data = parsedRaw as Record<string, unknown>;
    const usage = asRecord(data.usage);
    const outputTokensDetails = asRecord(usage?.["output_tokens_details"]);

    const inputTokens = numberValue(usage?.["input_tokens"]);
    const outputTokens = numberValue(usage?.["output_tokens"]);
    const totalTokens = Number(
      usage?.["total_tokens"] ?? inputTokens + outputTokens,
    );
    const reasoningTokens = Number(
      outputTokensDetails?.["reasoning_tokens"] ?? 0,
    );
    const visibleOutputTokens = Math.max(0, outputTokens - reasoningTokens);

    console.log("OpenAI responses usage", {
      uid,
      model: data?.model,
      inputTokens,
      outputTokens,
      reasoningTokens,
      visibleOutputTokens,
      totalTokens,
      requestId,
    });

    await requestLogRef.set(
      {
        status: "success",
        model: data?.model ?? body.model,
        tokenUsage: {
          promptTokens: inputTokens,
          completionTokens: outputTokens,
          totalTokens,
          reasoningTokens,
          outputTokens: visibleOutputTokens,
        },
        responseJson: data,
        updatedAt: FieldValue.serverTimestamp(),
        finishedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );

    return data;
  },
);

/**
 * Safely converts an unknown value into a record if possible.
 * @param {unknown} value
 * @return {Record<string, unknown> | null}
 */
function asRecord(value: unknown): Record<string, unknown> | null {
  return typeof value === "object" && value !== null ?
    value as Record<string, unknown> :
    null;
}

/**
 * Converts an unknown numeric payload field into a number.
 * @param {unknown} value
 * @return {number}
 */
function numberValue(value: unknown): number {
  return Number(value ?? 0);
}
