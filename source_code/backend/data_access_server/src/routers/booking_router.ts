import { Router } from "express";
import { createBooking, deleteBooking, getBooking, updateBooking } from "../controllers/booking_controller";

const router = Router();

router.post("/", createBooking); // TODO add httpRequest data validation step.

router.get("/", getBooking);

router.put("/:id", updateBooking); // TODO add httpRequest data validation step.

router.delete("/:id", deleteBooking);

export default router;