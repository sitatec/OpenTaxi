import { Router } from "express";
import { createAccount, deleteAccount, getAccount, updateAccount } from "../controllers/account_controller";

const router = Router();

router.post("/", createAccount);

router.get("/:id", getAccount); 

router.put("/:id", updateAccount);

router.delete("/:id", deleteAccount);

export default router;