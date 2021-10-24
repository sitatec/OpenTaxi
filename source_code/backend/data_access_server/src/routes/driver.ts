import { Router } from "express";
import { createDriver } from "../controllers/driver_controller";

const router = Router();

router.post("/", createDriver);

router.get("/:id", (req, res) => {

}); 

router.put("/:id", (req, res) => {

});

router.delete("/:id", (req, res) => {

});

const DriverRouter = router;

export default DriverRouter;