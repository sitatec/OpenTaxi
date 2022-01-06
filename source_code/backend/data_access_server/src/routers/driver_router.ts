import { Router } from "express";
import DriverController from "../controllers/driver_controller";

const driverController = new DriverController();

const router = Router();

router.post("/", driverController.createDriver); // TODO add httpRequest data validation step.

router.get("/data", driverController.getDriverData);

router.get("/data/:fields", driverController.getDriverData);

router.get("/", driverController.getDriver);

router.patch("/:account_id", driverController.updateDriver); // TODO add httpRequest data validation step.

router.delete("/:id", driverController.deleteDriver);

export default router;