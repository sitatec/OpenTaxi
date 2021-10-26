import { Router } from "express";
import { createRider, deleteRider, getRider, updateRider } from "../controllers/rider_controller";

const router = Router();

router.post("/", createRider); // TODO add httpRequest data validation step.

router.get("/", getRider);

router.put("/:id", updateRider); // TODO add httpRequest data validation step.

router.delete("/:id", deleteRider);

export default router;
