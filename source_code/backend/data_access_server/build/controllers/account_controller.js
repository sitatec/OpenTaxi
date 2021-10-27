"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteAccount = exports.updateAccount = exports.getAccount = exports.createAccount = void 0;
const security_1 = require("../security");
const _generic_controllers_1 = require("../controllers/_generic_controllers");
const createAccount = async (httpRequest, httpResponse) => (0, _generic_controllers_1.createEntity)("account", httpRequest, httpResponse);
exports.createAccount = createAccount;
const getAccount = (httpRequest, httpResponse) => (0, _generic_controllers_1.getEntity)("account", httpRequest, httpResponse);
exports.getAccount = getAccount;
const updateAccount = async (httpRequest, httpResponse) => {
    const requestBody = httpRequest.body;
    (0, security_1.preventUnauthorizedAccountUpdate)(requestBody, httpResponse.locals.userId);
    return (0, _generic_controllers_1.updateEntity)("account", httpRequest, httpResponse, requestBody);
};
exports.updateAccount = updateAccount;
const deleteAccount = async (httpRequest, httpResponse) => (0, _generic_controllers_1.deleteEntity)("account", httpRequest, httpResponse);
exports.deleteAccount = deleteAccount;
