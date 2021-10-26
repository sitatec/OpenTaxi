import { Router } from "express";
import { createTrip, deleteTrip, getTrip, updateTrip } from "../controllers/trip_controller";

const router = Router();

router.post("/", createTrip); // TODO add httpRequest data validation step.

router.get("/", getTrip);

router.put("/:id", updateTrip); // TODO add httpRequest data validation step.

router.delete("/:id", deleteTrip);

export default router;