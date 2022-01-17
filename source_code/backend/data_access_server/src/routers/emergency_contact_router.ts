import { Router } from "express";
import EmergencyContactController from "../controllers/emergency_contact_controller";

const emergencyContactController = new EmergencyContactController();

const router = Router();

router.post("/", emergencyContactController.createEmergencyContact); // TODO add httpRequest data validation step.

router.get("/", emergencyContactController.getEmergencyContact);

router.get("/:fields", emergencyContactController.getEmergencyContact);

router.patch("/:id", emergencyContactController.updateEmergencyContact); // TODO add httpRequest data validation step.

router.delete("/:id", emergencyContactController.deleteEmergencyContact);

export default router;