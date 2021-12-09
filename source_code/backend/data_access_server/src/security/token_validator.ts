import * as admin from "firebase-admin";

let firebaseAuth: admin.auth.Auth;

if (process.env.NODE_ENV != "test"){
   firebaseAuth = admin.initializeApp().auth();
}

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
  if(!token) {
    return INVALID_TOKEN_RESULT;
  }
  try {
    const decodedToken = await firebaseAuth.verifyIdToken(token);
    return {
      isValidToken: true,
      userId: decodedToken.uid,
    };
  } catch (e) {
    // TODO implement better error handling.
    console.error(e);
    return INVALID_TOKEN_RESULT;
  }
}; 
