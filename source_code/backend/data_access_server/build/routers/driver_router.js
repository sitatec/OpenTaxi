"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const driver_controller_1 = __importDefault(require("../controllers/driver_controller"));
const driverController = new driver_controller_1.default();
const router = (0, express_1.Router)();
router.post("/", driverController.createDriver); // TODO add httpRequest data validation step.
router.get("/", driverController.getDriver);
router.put("/:id", driverController.updateDriver); // TODO add httpRequest data validation step.
router.delete("/:id", driverController.deleteDriver);
exports.default = router;
