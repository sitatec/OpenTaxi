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

app.use("/car", RiderRouter);
app.use("/trip", RiderRouter);
app.use("/rider", RiderRouter);
app.use("/driver", DriverRouter);
app.use("/review", RiderRouter);
app.use("/account", AccountRouter);
app.use("/payment", RiderRouter);
app.use("/subscription", RiderRouter);

const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
  console.log(`Server started and listening ${PORT} port.`);
});
