import express from "express";
import { Database } from "./db";
import { isAdminUser } from "./security";
import { validateToken } from "./security/token_validator";
import Server from "./server";
import { extractTokenFromHeader } from "./utils/http_utils";

const app = express();
const SERVERS_ACCESS_TOKEN = "skfS43Z5ljSFSJS_sjzr-kss4643jslSGSAOPBN?p";
// TODO create a authentication system for the servers as well, instead of using a hard coded token.

app.use(async (httpRequest, httpResponse, next) => {
  // TODO install firebase emulators end test the security middlewares too, instead of skiping them.
  if (process.env.NODE_ENV == "test") return next();
  const token = extractTokenFromHeader(httpRequest.headers);
  if (!token) {
    httpResponse.status(401).end();
  }
  if(token == SERVERS_ACCESS_TOKEN) return next();
  const tokenValidationResult = await validateToken(token as string);
  if (!tokenValidationResult.isValidToken) {
    httpResponse.status(401).end();
  } else {
    httpResponse.locals.userId = tokenValidationResult.userId;
    next();
  }
});

app.delete("/", async (_, httpResponse, next) => {
  // TODO install firebase emulators end test the security middlewares too, instead of skiping them.
  if (process.env.NODE_ENV == "test") next();
  const isAdmin = await isAdminUser(httpResponse.locals.userId);
  if (!isAdmin) {
    httpResponse.status(401).end();
  } else {
    httpResponse.locals.role = "admin";
    next();
  }
});

app.use((_, res, next)  => {
  // Set the response content type for all endpoints responses.
  res.contentType('application/json');
  next();
});

const server = new Server(app);

Database.initialize();

server.start();
