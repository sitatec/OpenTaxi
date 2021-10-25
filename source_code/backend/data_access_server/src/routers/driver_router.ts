import { Router } from "express";
import {
  createDriver,
  deleteDriver,
  getDriver,
  updateDriver,
} from "../controllers/driver_controller";

const router = Router();

router.post("/", createDriver); // TODO add request data validation step.

router.get("/", getDriver);

router.put("/:id", updateDriver); // TODO add request data validation step.

router.delete("/:id", deleteDriver);

export default router;
