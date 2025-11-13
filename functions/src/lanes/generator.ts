import {onCall, HttpsError} from "firebase-functions/v2/https";
import {initializeApp, getApps} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {defineSecret} from "firebase-functions/params";

if (!getApps().length) {
  initializeApp();
}

const db = getFirestore();
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const generator = onCall(
  {
    region: "us-central1",
    secrets: [OPENAI_API_KEY],
    enforceAppCheck: true,
    cors: true,
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
      input: messages as any[],
      max_output_tokens: 5000,
      reasoning: {effort: "low"},
      text: {format: responseFormat},
    };

    const resp = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${OPENAI_API_KEY.value()}`,
      },
      body: JSON.stringify(body),
    });

    const raw = await resp.text();

    if (!resp.ok) {
      console.error("OpenAI error", {
        uid,
        status: resp.status,
        statusText: resp.statusText,
        requestId: resp.headers.get("x-request-id") ?? undefined,
      });

      // Не пробрасываем сырые данные клиенту!
      throw new HttpsError(
        "unknown",
        "The service is temporarily unavailable.\nPlease try again shortly.",
      );
    }

    const data = JSON.parse(raw);

    // Token stats
    const usage = data?.usage ?? {};
    const inputTokens = Number(usage.input_tokens ?? 0);
    const outputTokens = Number(usage.output_tokens ?? 0);
    const totalTokens = Number(
      usage.total_tokens ?? inputTokens + outputTokens,
    );
    const reasoningTokens = Number(
      usage?.output_tokens_details?.reasoning_tokens ?? 0,
    );
    const visibleOutputTokens = Math.max(0, outputTokens - reasoningTokens);

    // Безопасный лог
    console.log("OpenAI responses usage", {
      uid,
      model: data?.model,
      inputTokens,
      outputTokens,
      reasoningTokens,
      visibleOutputTokens,
      totalTokens,
      requestId: resp.headers.get("x-request-id") ?? undefined,
    });

    // Firestore write
    await Promise.all([
      db.collection("assistants").doc("generator").set(
        {
          promptTokens: FieldValue.increment(inputTokens),
          completionTokens: FieldValue.increment(outputTokens),
          totalTokens: FieldValue.increment(totalTokens),
          reasoningTokens: FieldValue.increment(reasoningTokens),
          outputTokens: FieldValue.increment(visibleOutputTokens),
          requestCount: FieldValue.increment(1),
        },
        {merge: true},
      ),
    ]);

    return data;
  },
);
