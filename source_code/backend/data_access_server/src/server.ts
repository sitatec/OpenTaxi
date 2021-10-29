import express, { Application }from "express";
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
import { Server as HttpServer } from "http";

  
const PORT = process.env.PORT || 8080;

export default class Server {

  private httpServer?: HttpServer; 

  constructor(private app: Application = express()){
    app.use(express.json());
    this.setupRouters();
  }

  private setupRouters() {
    this.app.use("/car", CarRouter);
    this.app.use("/trip", TripRouter);
    this.app.use("/rider", RiderRouter);
    this.app.use("/review", ReviewRouter);
    this.app.use("/driver", DriverRouter);
    this.app.use("/payment", PaymentRouter);
    this.app.use("/booking", BookingRouter);
    this.app.use("/account", AccountRouter);
    this.app.use("/subscription", SubscriptionRouter);
  }

  start() {
    this.httpServer = this.app.listen(PORT, () => {
      console.log(`Server started and listening ${PORT} port.`);
    });
  }

  stop(){
    this.httpServer?.close();
  }


}