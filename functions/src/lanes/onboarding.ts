import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getApps, initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();

function userDocument(uid: string) {
  return db.collection("users").doc(uid);
}

export const onboardingResponses = onCall(
  {
    region: "us-central1",
    enforceAppCheck: false,
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
            name: typeof name === "object" && name ? name : null,
            gender: typeof gender === "object" && gender ? gender : null,
            age: typeof age === "object" && age ? age : null,
            country: typeof country === "object" && country ? country : null,
            aboutUs: typeof aboutUs === "object" && aboutUs ? aboutUs : null,
            updatedAt: FieldValue.serverTimestamp(),
          },
          {merge: true},
        ),
    ]);

    return {ok: true};
  },
);
