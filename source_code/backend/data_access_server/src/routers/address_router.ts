import { Router } from "express";
import AddressController from "../controllers/address_controller";

const addressController = new AddressController();

const router = Router();

router.post("/", addressController.createAddress); // TODO add httpRequest data validation step.

router.get("/", addressController.getAddress);

router.get("/:fields", addressController.getAddress);

router.patch("/:id", addressController.updateAddress); // TODO add httpRequest data validation step.

router.delete("/:id", addressController.deleteAddress);

export default router;