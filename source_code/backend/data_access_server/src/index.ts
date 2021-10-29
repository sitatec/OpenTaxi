import express from "express";
import { Database } from "./db";
import { isAdminUser } from "./security";
import { validateToken } from "./security/token_validator";
import Server from "./server";
import { extractTokenFromHeader } from "./utils/http_utils";

const app = express();

app.use(async (httpRequest, httpResponse, next) => {
  const token = extractTokenFromHeader(httpRequest.headers);
  if (!token) {
    httpResponse.status(401).end();
  }
  const tokenValidationResult = await validateToken(token as string);
  if (!tokenValidationResult.isValidToken) {
    httpResponse.status(401).end();
  } else {
    httpResponse.locals.userId = tokenValidationResult.userId;
    next();
  }
});
 
app.delete("/", async (_, httpResponse, next) => {
  const isAdmin = await isAdminUser(httpResponse.locals.userId);
  if (!isAdmin) {
    httpResponse.status(401).end();
  } else {
    httpResponse.locals.role = "admin";
    next();
  }
});

const server = new Server(app);

Database.initialize();

server.start();
