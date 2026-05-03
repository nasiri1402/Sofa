import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getApps, initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();

/**
 * Returns the Firestore user document reference for the given uid.
 * @param {string} uid
 * @return {FirebaseFirestore.DocumentReference}
 */
function userDocument(uid: string) {
  return db.collection("users").doc(uid);
}

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
 * Returns a string value when the payload field is a string.
 * @param {unknown} value
 * @return {string | null}
 */
function stringValue(value: unknown): string | null {
  return typeof value === "string" ? value : null;
}

/**
 * Returns a number value when the payload field is a finite number.
 * @param {unknown} value
 * @return {number | null}
 */
function numberValue(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

/**
 * Stores onboarding answers for the authenticated user.
 */
export const onboardingResponses = onCall(
  {
    region: "us-central1",
    enforceAppCheck: true,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Auth required.");
    }

    const {
      name,
      gender,
      age,
      country,
      aboutUs,
    } = request.data ?? {};

    await Promise.all([
      userDocument(uid).set(
        {
          uid,
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
      ),
      userDocument(uid)
        .collection("onboarding")
        .doc("responses")
        .set(
          {
            name: stringValue(asRecord(name)?.["name"]),
            gender: stringValue(asRecord(gender)?.["gender"]),
            age: numberValue(asRecord(age)?.["age"]),
            country: {
              isoCode: stringValue(asRecord(country)?.["isoCode"]),
              name: stringValue(asRecord(country)?.["name"]),
            },
            aboutUs: {
              source: stringValue(asRecord(aboutUs)?.["source"]),
              other: stringValue(asRecord(aboutUs)?.["other"]),
            },
            updatedAt: FieldValue.serverTimestamp(),
          },
          {merge: true},
        ),
    ]);

    return {ok: true};
  },
);
