import { Router } from "express";
import SubscriptionController from "../controllers/subscription_controller";

const subscriptionController = new SubscriptionController();

const router = Router();

router.post("/", subscriptionController.createSubscription); // TODO add httpRequest data validation step.

router.get("/", subscriptionController.getSubscription);

router.get("/:fields", subscriptionController.getSubscription);

router.patch("/:id", subscriptionController.updateSubscription); // TODO add httpRequest data validation step.

router.delete("/:id", subscriptionController.deleteSubscription);

export default router;