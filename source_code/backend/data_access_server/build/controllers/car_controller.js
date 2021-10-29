"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const controller_1 = __importDefault(require("./controller"));
class CarController extends controller_1.default {
    constructor() {
        super(...arguments);
        this.createCar = async (httpRequest, httpResponse) => this.entityManager.createEntity("car", httpRequest, httpResponse);
        this.getCar = (httpRequest, httpResponse) => this.entityManager.getEntity("car", httpRequest, httpResponse);
        this.updateCar = async (httpRequest, httpResponse) => this.entityManager.updateEntity("car", httpRequest, httpResponse);
        this.deleteCar = async (httpRequest, httpResponse) => this.entityManager.deleteEntity("car", httpRequest, httpResponse);
    }
}
exports.default = CarController;
