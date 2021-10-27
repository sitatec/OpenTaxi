"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const payment_controller_1 = require("../controllers/payment_controller");
const router = (0, express_1.Router)();
router.post("/", payment_controller_1.createPayment); // TODO add httpRequest data validation step.
router.get("/", payment_controller_1.getPayment);
router.put("/:id", payment_controller_1.updatePayment); // TODO add httpRequest data validation step.
router.delete("/:id", payment_controller_1.deletePayment);
exports.default = router;
