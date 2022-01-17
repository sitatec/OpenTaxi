import express, { Application } from "express";
import DriverRouter from "./routers/driver_router";
import AccountRouter from "./routers/account_router";
import VehicleRouter from "./routers/vehicle_router";
import TripRouter from "./routers/trip_router";
import ReviewRouter from "./routers/review_router";
import PaymentRouter from "./routers/payment_router";
import BookingRouter from "./routers/booking_router";
import RiderRouter from "./routers/rider_router";
import AddressRouter from "./routers/address_router";
import EmergencyContactRouter from "./routers/emergency_contact_router";
import BankAccountRouter from "./routers/bank_account_router";
import { Server as HttpServer } from "http";

const PORT = process.env.PORT || 8080;

export default class Server {
  private httpServer?: HttpServer;

  constructor(private app: Application = express()) {
    app.use(express.json());
    this.setupRouters();
  }

  private setupRouters() {
    this.app.use("/car", VehicleRouter);
    this.app.use("/trip", TripRouter);
    this.app.use("/rider", RiderRouter);
    this.app.use("/review", ReviewRouter);
    this.app.use("/driver", DriverRouter);
    this.app.use("/payment", PaymentRouter);
    this.app.use("/booking", BookingRouter);
    this.app.use("/account", AccountRouter);
    this.app.use("/address", AddressRouter);
    this.app.use("/emergency_contact", EmergencyContactRouter);
    this.app.use("/bank_account", BankAccountRouter);
  }

  start() {
    this.httpServer = this.app.listen(PORT, () => {
      console.log(`Server started and listening ${PORT} port.`);
    });
  }

  stop() {
    this.httpServer?.close();
  }
}
