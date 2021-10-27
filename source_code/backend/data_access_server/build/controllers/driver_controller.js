"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteDriver = exports.updateDriver = exports.getDriver = exports.createDriver = void 0;
const _generic_controllers_1 = require("./_generic_controllers");
const account_controller_1 = require("./account_controller");
const createDriver = async (httpRequest, httpResponse) => (0, _generic_controllers_1.createEntityWithRelation)("account", "driver", httpRequest, httpResponse);
exports.createDriver = createDriver;
const getDriver = async (httpRequest, httpResponse) => (0, _generic_controllers_1.getEntityWithRelation)("account", "driver", httpRequest, httpResponse);
exports.getDriver = getDriver;
const updateDriver = async (httpRequest, httpResponse) => (0, _generic_controllers_1.updateEntityWithRelation)("account", "driver", httpRequest, httpResponse);
exports.updateDriver = updateDriver;
exports.deleteDriver = account_controller_1.deleteAccount; // Deleting the account will delete the
// driver data too, because a CASCADE constraint is specified on the account_id
// column.
