import { initializeApp } from "firebase-admin";

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
  if(!token) {
    return INVALID_TOKEN_RESULT;
  }
  /* For now we have a hard coded "token" for our auth server so it will be able
    to send request to this server for creating users when registering.
    TODO implement a JWT authentication for the servers too. */
  if(token == "__auth_server__LSsj46flS.KJF_:alr446ojSVioà-(zlvslkf46lSDF37kj"){
    return {
      isValidToken: true,
      userId: "authentication_server",
    };
  } else {
    return validateClientToken(token);
  }
};

const validateClientToken = async (token: string): Promise<TokenValidationResult> => {
  try {
    const decodedToken = await firebaseAuth.verifyIdToken(token);
    return {
      isValidToken: true,
      userId: decodedToken.uid,
    };
  } catch (e) {
    // TODO implement better error handling.
    return INVALID_TOKEN_RESULT;
  }
};
