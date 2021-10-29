"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const controller_1 = __importDefault(require("./controller"));
class SubscriptionController extends controller_1.default {
    constructor() {
        super(...arguments);
        this.createSubscription = async (httpRequest, httpResponse) => this.entityManager.createEntity("subscription", httpRequest, httpResponse);
        this.getSubscription = (httpRequest, httpResponse) => this.entityManager.getEntity("subscription", httpRequest, httpResponse);
        this.updateSubscription = async (httpRequest, httpResponse) => this.entityManager.updateEntity("subscription", httpRequest, httpResponse);
        this.deleteSubscription = async (httpRequest, httpResponse) => this.entityManager.deleteEntity("subscription", httpRequest, httpResponse);
    }
}
exports.default = SubscriptionController;
