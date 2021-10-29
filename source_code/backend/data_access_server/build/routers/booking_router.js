"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const booking_controller_1 = __importDefault(require("../controllers/booking_controller"));
const bookingController = new booking_controller_1.default();
const router = (0, express_1.Router)();
router.post("/", bookingController.createBooking); // TODO add httpRequest data validation step.
router.get("/", bookingController.getBooking);
router.put("/:id", bookingController.updateBooking); // TODO add httpRequest data validation step.
router.delete("/:id", bookingController.deleteBooking);
exports.default = router;
