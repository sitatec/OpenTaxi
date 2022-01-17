import { Router } from "express";
import VehicleController from "../controllers/vehicle_controller";

const vehicleController = new VehicleController();

const router = Router();

router.post("/", vehicleController.createVehicle); // TODO add httpRequest data validation step.

router.get("/", vehicleController.getVehicle);

router.get("/:fields", vehicleController.getVehicle);

router.patch("/:id", vehicleController.updateVehicle); // TODO add httpRequest data validation step.

router.delete("/:id", vehicleController.deleteVehicle);

export default router;
