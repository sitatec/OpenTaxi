"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const rider_controller_1 = require("../controllers/rider_controller");
const router = (0, express_1.Router)();
router.post("/", rider_controller_1.createRider); // TODO add httpRequest data validation step.
router.get("/", rider_controller_1.getRider);
router.get("/favorite_drivers", rider_controller_1.getFavoriteDrivers);
router.put("/:id", rider_controller_1.updateRider); // TODO add httpRequest data validation step.
router.delete("/:id", rider_controller_1.deleteRider);
exports.default = router;
