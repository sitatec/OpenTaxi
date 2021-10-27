"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deletePayment = exports.updatePayment = exports.getPayment = exports.createPayment = void 0;
const _generic_controllers_1 = require("./_generic_controllers");
const createPayment = async (httpRequest, httpResponse) => (0, _generic_controllers_1.createEntity)("payment", httpRequest, httpResponse);
exports.createPayment = createPayment;
const getPayment = (httpRequest, httpResponse) => (0, _generic_controllers_1.getEntity)("payment", httpRequest, httpResponse);
exports.getPayment = getPayment;
const updatePayment = async (httpRequest, httpResponse) => (0, _generic_controllers_1.updateEntity)("payment", httpRequest, httpResponse);
exports.updatePayment = updatePayment;
const deletePayment = async (httpRequest, httpResponse) => (0, _generic_controllers_1.deleteEntity)("payment", httpRequest, httpResponse);
exports.deletePayment = deletePayment;
