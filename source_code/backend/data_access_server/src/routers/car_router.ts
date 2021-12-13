import { Router } from "express";
import CarController from "../controllers/car_controller";

const carController = new CarController();

const router = Router();

router.post("/", carController.createCar); // TODO add httpRequest data validation step.

router.get("/", carController.getCar);

router.patch("/:id", carController.updateCar); // TODO add httpRequest data validation step.

router.delete("/:id", carController.deleteCar);

export default router;
