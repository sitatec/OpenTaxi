import { Router } from "express";
import TripController from "../controllers/trip_controller";

const tripController = new TripController();

const router = Router();

router.post("/", tripController.createTrip); // TODO add httpRequest data validation step.

router.get("/", tripController.getTrip);

router.get("/:fields", tripController.getTrip);

router.patch("/:id", tripController.updateTrip); // TODO add httpRequest data validation step.

router.delete("/:id", tripController.deleteTrip);

export default router;