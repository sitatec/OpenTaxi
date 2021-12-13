import { Router } from "express";
import ReviewController from "../controllers/review_controller";

const reviewController = new ReviewController();

const router = Router();

router.post("/", reviewController.createReview); // TODO add httpRequest data validation step.

router.get("/", reviewController.getReview);

router.patch("/:id", reviewController.updateReview); // TODO add httpRequest data validation step.

router.delete("/:id", reviewController.deleteReview);

export default router;