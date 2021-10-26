import express from "express";
import DriverRouter from "./routers/driver_router";
import AccountRouter from "./routers/account_router";
import { isAdminUser, validateToken } from "./security";
import { extractTokenFromHeader } from "./utils/http_utils";
import RiderRouter from "./routers/rider_router";

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
    httpResponse.locals.sendSuccessResponse = (statusCode: number | undefined) => {
      httpResponse.status(statusCode || 200).send({ status: "success" })
    }
    next();
  }
});

app.delete("/", async (httpRequest, httpResponse, next) => {
  const isAdmin = await isAdminUser(httpResponse.locals.userId);
  if (!isAdmin) {
    httpResponse.status(401).end();
  } else {
    httpResponse.locals.role = "admin";
    next();
  }
});


app.use("/account", AccountRouter);
app.use("/driver", DriverRouter);
app.use("/rider", RiderRouter)

const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
  console.log(`Server started and listening ${PORT} port.`);
});
