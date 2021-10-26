import { Router } from "express";
import { createReview, deleteReview, getReview, updateReview } from "../controllers/review_controller";
import { createRider, deleteRider, getRider, updateRider } from "../controllers/rider_controller";

const router = Router();

router.post("/", createReview); // TODO add httpRequest data validation step.

router.get("/", getReview);

router.put("/:id", updateReview); // TODO add httpRequest data validation step.

router.delete("/:id", deleteReview);

export default router;