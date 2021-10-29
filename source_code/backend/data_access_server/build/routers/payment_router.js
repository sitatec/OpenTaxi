"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const payment_controller_1 = __importDefault(require("../controllers/payment_controller"));
const paymentController = new payment_controller_1.default();
const router = (0, express_1.Router)();
router.post("/", paymentController.createPayment); // TODO add httpRequest data validation step.
router.get("/", paymentController.getPayment);
router.put("/:id", paymentController.updatePayment); // TODO add httpRequest data validation step.
router.delete("/:id", paymentController.deletePayment);
exports.default = router;
