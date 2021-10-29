import { Router } from "express";
import PaymentController from "../controllers/payment_controller";

const paymentController = new PaymentController();

const router = Router();

router.post("/", paymentController.createPayment); // TODO add httpRequest data validation step.

router.get("/", paymentController.getPayment);

router.put("/:id", paymentController.updatePayment); // TODO add httpRequest data validation step.

router.delete("/:id", paymentController.deletePayment);

export default router;