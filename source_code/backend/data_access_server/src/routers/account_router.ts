import { Router } from "express";
import {
  createAccount,
  deleteAccount,
  getAccount,
  updateAccount,
} from "../controllers/account_controller";

const router = Router();

router.post("/", createAccount); // TODO add request data validation step.

router.get("/:id", getAccount);

router.put("/:id", updateAccount); // TODO add request data validation step.

router.delete("/:id", deleteAccount);

export default router;
