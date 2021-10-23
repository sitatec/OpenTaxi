import { initializeApp } from "firebase-admin";
import { DecodedIdToken } from "../../node_modules/firebase-admin/lib/auth/token-verifier";

const firebaseAuth = initializeApp().auth();

interface TokenValidationResult {
  isValidToken: boolean;
  userId: string | null;
}

const INVALID_TOKEN_RESULT = {
  isValidToken: false,
  userId: null,
};

export const validateToken = async (
  token: string
): Promise<TokenValidationResult> => {
  if(!token) return INVALID_TOKEN_RESULT
  try {
    const decodedToken = await firebaseAuth.verifyIdToken(token);
    return {
      isValidToken: true,
      userId: decodedToken.uid,
    };
  } catch (e) {
    return INVALID_TOKEN_RESULT;
  }
};