import { Router } from "express";
import BankAccountController from "../controllers/bank_account_controller";

const bankAccountController = new BankAccountController();

const router = Router();

router.post("/", bankAccountController.createBankAccount); // TODO add httpRequest data validation step.

router.get("/", bankAccountController.getBankAccount);

router.get("/:fields", bankAccountController.getBankAccount);

router.patch("/:id", bankAccountController.updateBankAccount); // TODO add httpRequest data validation step.

router.delete("/:id", bankAccountController.deleteBankAccount);

export default router;