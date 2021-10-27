"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const review_controller_1 = require("../controllers/review_controller");
const router = (0, express_1.Router)();
router.post("/", review_controller_1.createReview); // TODO add httpRequest data validation step.
router.get("/", review_controller_1.getReview);
router.put("/:id", review_controller_1.updateReview); // TODO add httpRequest data validation step.
router.delete("/:id", review_controller_1.deleteReview);
exports.default = router;
