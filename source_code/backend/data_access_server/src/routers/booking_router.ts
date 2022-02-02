import { Router } from "express";
import BookingController from "../controllers/booking_controller";

const bookingController = new BookingController();

const router = Router();

router.post("/", bookingController.createBooking); // TODO add httpRequest data validation step.

router.post("/with_addresses", bookingController.createBookingWithAddresses);

router.get("/", bookingController.getBooking);

router.get("/addresses", bookingController.getBookingAddresses);

router.get("/:fields", bookingController.getBooking);

router.patch("/:id", bookingController.updateBooking); // TODO add httpRequest data validation step.

router.delete("/:id", bookingController.deleteBooking);

export default router;