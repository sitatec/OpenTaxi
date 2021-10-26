import { Router } from "express";
import { createPayment, deletePayment, getPayment, updatePayment } from "../controllers/payment_controller";

const router = Router();

router.post("/", createPayment); // TODO add httpRequest data validation step.

router.get("/", getPayment);

router.put("/:id", updatePayment); // TODO add httpRequest data validation step.

router.delete("/:id", deletePayment);

export default router;