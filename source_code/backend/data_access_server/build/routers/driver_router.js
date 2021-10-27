"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const driver_controller_1 = require("../controllers/driver_controller");
const router = (0, express_1.Router)();
router.post("/", driver_controller_1.createDriver); // TODO add httpRequest data validation step.
router.get("/", driver_controller_1.getDriver);
router.put("/:id", driver_controller_1.updateDriver); // TODO add httpRequest data validation step.
router.delete("/:id", driver_controller_1.deleteDriver);
exports.default = router;
