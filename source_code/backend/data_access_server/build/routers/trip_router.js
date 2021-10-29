"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const trip_controller_1 = __importDefault(require("../controllers/trip_controller"));
const tripController = new trip_controller_1.default();
const router = (0, express_1.Router)();
router.post("/", tripController.createTrip); // TODO add httpRequest data validation step.
router.get("/", tripController.getTrip);
router.put("/:id", tripController.updateTrip); // TODO add httpRequest data validation step.
router.delete("/:id", tripController.deleteTrip);
exports.default = router;
