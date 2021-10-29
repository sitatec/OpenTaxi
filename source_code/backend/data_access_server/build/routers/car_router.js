"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const car_controller_1 = __importDefault(require("../controllers/car_controller"));
const carController = new car_controller_1.default();
const router = (0, express_1.Router)();
router.post("/", carController.createCar); // TODO add httpRequest data validation step.
router.get("/", carController.getCar);
router.put("/:id", carController.updateCar); // TODO add httpRequest data validation step.
router.delete("/:id", carController.deleteCar);
exports.default = router;
