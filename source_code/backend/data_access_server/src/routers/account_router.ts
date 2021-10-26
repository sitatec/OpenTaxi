import { Router } from "express";
import {
  createAccount,
  deleteAccount,
  getAccount,
  updateAccount,
} from "../controllers/account_controller";

const router = Router();

router.post("/", createAccount); // TODO add httpRequest data validation step.

router.get("/", getAccount);

router.put("/:id", updateAccount); // TODO add httpRequest data validation step.

router.delete("/:id", deleteAccount);

export default router;
