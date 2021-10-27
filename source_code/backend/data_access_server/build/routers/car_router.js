"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const car_controller_1 = require("../controllers/car_controller");
const router = (0, express_1.Router)();
router.post("/", car_controller_1.createCar); // TODO add httpRequest data validation step.
router.get("/", car_controller_1.getCar);
router.put("/:id", car_controller_1.updateCar); // TODO add httpRequest data validation step.
router.delete("/:id", car_controller_1.deleteCar);
exports.default = router;
