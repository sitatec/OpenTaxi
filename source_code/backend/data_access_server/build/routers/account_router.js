"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const account_controller_1 = require("../controllers/account_controller");
const router = (0, express_1.Router)();
router.post("/", account_controller_1.createAccount); // TODO add httpRequest data validation step.
router.get("/", account_controller_1.getAccount);
router.put("/:id", account_controller_1.updateAccount); // TODO add httpRequest data validation step.
router.delete("/:id", account_controller_1.deleteAccount);
exports.default = router;
