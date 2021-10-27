"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.startServer = void 0;
const express_1 = __importDefault(require("express"));
const driver_router_1 = __importDefault(require("./routers/driver_router"));
const account_router_1 = __importDefault(require("./routers/account_router"));
const car_router_1 = __importDefault(require("./routers/car_router"));
const trip_router_1 = __importDefault(require("./routers/trip_router"));
const review_router_1 = __importDefault(require("./routers/review_router"));
const payment_router_1 = __importDefault(require("./routers/payment_router"));
const booking_router_1 = __importDefault(require("./routers/booking_router"));
const subscription_router_1 = __importDefault(require("./routers/subscription_router"));
// import { isAdminUser, validateToken } from "./security";
// import { extractTokenFromHeader } from "./utils/http_utils";
const rider_router_1 = __importDefault(require("./routers/rider_router"));
const app = (0, express_1.default)();
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
const startServer = (() => {
    app.use(express_1.default.json());
    app.use("/car", car_router_1.default);
    app.use("/trip", trip_router_1.default);
    app.use("/rider", rider_router_1.default);
    app.use("/review", review_router_1.default);
    app.use("/driver", driver_router_1.default);
    app.use("/payment", payment_router_1.default);
    app.use("/booking", booking_router_1.default);
    app.use("/account", account_router_1.default);
    app.use("/subscription", subscription_router_1.default);
    const PORT = process.env.PORT || 8080;
    return app.listen(PORT, () => {
        console.log(`Server started and listening ${PORT} port.`);
    });
})();

exports.startServer = startServer;
