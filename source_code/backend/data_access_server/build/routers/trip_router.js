"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const trip_controller_1 = require("../controllers/trip_controller");
const router = (0, express_1.Router)();
router.post("/", trip_controller_1.createTrip); // TODO add httpRequest data validation step.
router.get("/", trip_controller_1.getTrip);
router.put("/:id", trip_controller_1.updateTrip); // TODO add httpRequest data validation step.
router.delete("/:id", trip_controller_1.deleteTrip);
exports.default = router;
