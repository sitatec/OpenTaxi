"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const controller_1 = __importDefault(require("./controller"));
class PaymentController extends controller_1.default {
    constructor() {
        super(...arguments);
        this.createPayment = async (httpRequest, httpResponse) => this.entityManager.createEntity("payment", httpRequest, httpResponse);
        this.getPayment = (httpRequest, httpResponse) => this.entityManager.getEntity("payment", httpRequest, httpResponse);
        this.updatePayment = async (httpRequest, httpResponse) => this.entityManager.updateEntity("payment", httpRequest, httpResponse);
        this.deletePayment = async (httpRequest, httpResponse) => this.entityManager.deleteEntity("payment", httpRequest, httpResponse);
    }
}
exports.default = PaymentController;
