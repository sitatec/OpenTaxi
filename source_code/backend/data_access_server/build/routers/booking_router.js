"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const booking_controller_1 = require("../controllers/booking_controller");
const router = (0, express_1.Router)();
router.post("/", booking_controller_1.createBooking); // TODO add httpRequest data validation step.
router.get("/", booking_controller_1.getBooking);
router.put("/:id", booking_controller_1.updateBooking); // TODO add httpRequest data validation step.
router.delete("/:id", booking_controller_1.deleteBooking);
exports.default = router;
