import { Router } from "express";
import {
  createDriver,
  deleteDriver,
  getDriver,
  updateDriver,
} from "../controllers/driver_controller";

const router = Router();

router.post("/", createDriver); // TODO add httpRequest data validation step.

router.get("/", getDriver);

router.put("/:account_id", updateDriver); // TODO add httpRequest data validation step.

router.delete("/:id", deleteDriver);

export default router;
