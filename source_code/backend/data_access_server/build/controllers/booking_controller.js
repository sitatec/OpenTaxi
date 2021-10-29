"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const controller_1 = __importDefault(require("./controller"));
class BookingController extends controller_1.default {
    constructor() {
        super(...arguments);
        this.createBooking = async (httpRequest, httpResponse) => this.entityManager.createEntity("booking", httpRequest, httpResponse);
        this.getBooking = (httpRequest, httpResponse) => this.entityManager.getEntity("booking", httpRequest, httpResponse);
        this.updateBooking = async (httpRequest, httpResponse) => this.entityManager.updateEntity("booking", httpRequest, httpResponse);
        this.deleteBooking = async (httpRequest, httpResponse) => this.entityManager.deleteEntity("booking", httpRequest, httpResponse);
    }
}
exports.default = BookingController;
