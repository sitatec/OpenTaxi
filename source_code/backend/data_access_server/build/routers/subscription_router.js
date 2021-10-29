"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const subscription_controller_1 = __importDefault(require("../controllers/subscription_controller"));
const subscriptionController = new subscription_controller_1.default();
const router = (0, express_1.Router)();
router.post("/", subscriptionController.createSubscription); // TODO add httpRequest data validation step.
router.get("/", subscriptionController.getSubscription);
router.put("/:id", subscriptionController.updateSubscription); // TODO add httpRequest data validation step.
router.delete("/:id", subscriptionController.deleteSubscription);
exports.default = router;
