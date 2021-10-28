import { Router } from "express";
import {
  createCar,
  deleteCar,
  getCar,
  updateCar,
} from "../controllers/car_controller";

const router = Router();

router.post("/", createCar); // TODO add httpRequest data validation step.

router.get("/", getCar);

router.put("/:id", updateCar); // TODO add httpRequest data validation step.

router.delete("/:id", deleteCar);

export default router;
