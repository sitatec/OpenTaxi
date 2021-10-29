"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const controller_1 = __importDefault(require("./controller"));
class ReviewController extends controller_1.default {
    constructor() {
        super(...arguments);
        this.createReview = async (httpRequest, httpResponse) => this.entityManager.createEntity("review", httpRequest, httpResponse);
        this.getReview = (httpRequest, httpResponse) => this.entityManager.getEntity("review", httpRequest, httpResponse);
        this.updateReview = async (httpRequest, httpResponse) => this.entityManager.updateEntity("review", httpRequest, httpResponse);
        this.deleteReview = async (httpRequest, httpResponse) => this.entityManager.deleteEntity("review", httpRequest, httpResponse);
    }
}
exports.default = ReviewController;
