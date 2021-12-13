import { Router } from "express";
import AccountController from "../controllers/account_controller";

const router = Router();

const accountController = new AccountController();

router.post("/", accountController.createAccount); // TODO add httpRequest data validation step.

router.get("/notification_token", accountController.getNotificationToken);

router.get("/", accountController.getAccount);

router.patch("/:id", accountController.updateAccount); // TODO add httpRequest data validation step.

router.delete("/:id", accountController.deleteAccount);

export default router;
