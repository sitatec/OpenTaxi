"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const security_1 = require("../security");
const controller_1 = __importDefault(require("./controller"));
class AccountController extends controller_1.default {
    constructor() {
        super(...arguments);
        this.createAccount = async (httpRequest, httpResponse) => this.entityManager.createEntity("account", httpRequest, httpResponse);
        this.getAccount = (httpRequest, httpResponse) => this.entityManager.getEntity("account", httpRequest, httpResponse);
        this.updateAccount = async (httpRequest, httpResponse) => {
            (0, security_1.preventUnauthorizedAccountUpdate)(httpRequest.body, httpResponse.locals.userId);
            return this.entityManager.updateEntity("account", httpRequest, httpResponse);
        };
        this.deleteAccount = async (httpRequest, httpResponse) => this.entityManager.deleteEntity("account", httpRequest, httpResponse);
    }
}
exports.default = AccountController;
