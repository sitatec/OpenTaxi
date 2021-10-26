import { Router } from "express";
import { createSubscription, deleteSubscription, getSubscription, updateSubscription } from "../controllers/subscription_controller";

const router = Router();

router.post("/", createSubscription); // TODO add httpRequest data validation step.

router.get("/", getSubscription);

router.put("/:id", updateSubscription); // TODO add httpRequest data validation step.

router.delete("/:id", deleteSubscription);

export default router;