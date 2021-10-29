"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const account_controller_1 = __importDefault(require("../controllers/account_controller"));
const router = (0, express_1.Router)();
const accountController = new account_controller_1.default();
router.post("/", accountController.createAccount); // TODO add httpRequest data validation step.
router.get("/", accountController.getAccount);
router.put("/:id", accountController.updateAccount); // TODO add httpRequest data validation step.
router.delete("/:id", accountController.deleteAccount);
exports.default = router;
