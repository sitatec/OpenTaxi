"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const controller_1 = __importDefault(require("./controller"));
class TripController extends controller_1.default {
    constructor() {
        super(...arguments);
        this.createTrip = async (httpRequest, httpResponse) => this.entityManager.createEntity("trip", httpRequest, httpResponse);
        this.getTrip = (httpRequest, httpResponse) => this.entityManager.getEntity("trip", httpRequest, httpResponse);
        this.updateTrip = async (httpRequest, httpResponse) => this.entityManager.updateEntity("trip", httpRequest, httpResponse);
        this.deleteTrip = async (httpRequest, httpResponse) => this.entityManager.deleteEntity("trip", httpRequest, httpResponse);
    }
}
exports.default = TripController;
