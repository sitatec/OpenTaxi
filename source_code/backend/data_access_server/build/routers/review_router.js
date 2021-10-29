"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const review_controller_1 = __importDefault(require("../controllers/review_controller"));
const reviewController = new review_controller_1.default();
const router = (0, express_1.Router)();
router.post("/", reviewController.createReview); // TODO add httpRequest data validation step.
router.get("/", reviewController.getReview);
router.put("/:id", reviewController.updateReview); // TODO add httpRequest data validation step.
router.delete("/:id", reviewController.deleteReview);
exports.default = router;
