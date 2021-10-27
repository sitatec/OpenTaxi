import express from "express";
import DriverRouter from "./routers/driver_router";
import AccountRouter from "./routers/account_router";
import CarRouter from "./routers/car_router";
import TripRouter from "./routers/trip_router";
import ReviewRouter from "./routers/review_router";
import PaymentRouter from "./routers/payment_router";
import BookingRouter from "./routers/booking_router";
import SubscriptionRouter from "./routers/subscription_router";
// import { isAdminUser, validateToken } from "./security";
// import { extractTokenFromHeader } from "./utils/http_utils";
import RiderRouter from "./routers/rider_router";

const app = express();

// app.use(async (httpRequest, httpResponse, next) => {
//   const token = extractTokenFromHeader(httpRequest.headers);
//   if (!token) {
//     httpResponse.status(401).end();
//   }
//   const tokenValidationResult = await validateToken(token as string);
//   if (!tokenValidationResult.isValidToken) {
//     httpResponse.status(401).end();
//   } else {
//     httpResponse.locals.userId = tokenValidationResult.userId;
//     next();
//   }
// });

// app.delete("/", async (_, httpResponse, next) => {
//   const isAdmin = await isAdminUser(httpResponse.locals.userId);
//   if (!isAdmin) {
//     httpResponse.status(401).end();
//   } else {
//     httpResponse.locals.role = "admin";
//     next();
//   }
// });

export const startServer = () => {
app.use(express.json());

app.use("/car", CarRouter);
app.use("/trip", TripRouter);
app.use("/rider", RiderRouter);
app.use("/review", ReviewRouter);
app.use("/driver", DriverRouter);
app.use("/payment", PaymentRouter);
app.use("/booking", BookingRouter);
app.use("/account", AccountRouter);
app.use("/subscription", SubscriptionRouter);

const PORT = process.env.PORT || 8080;

return app.listen(PORT, () => {
  console.log(`Server started and listening ${PORT} port.`);
});
}
