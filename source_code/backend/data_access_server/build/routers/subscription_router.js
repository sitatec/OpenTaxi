"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const subscription_controller_1 = require("../controllers/subscription_controller");
const router = (0, express_1.Router)();
router.post("/", subscription_controller_1.createSubscription); // TODO add httpRequest data validation step.
router.get("/", subscription_controller_1.getSubscription);
router.put("/:id", subscription_controller_1.updateSubscription); // TODO add httpRequest data validation step.
router.delete("/:id", subscription_controller_1.deleteSubscription);
exports.default = router;
