"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteRider = exports.updateRider = exports.getFavoriteDrivers = exports.getRider = exports.createRider = void 0;
const _generic_controllers_1 = require("../controllers/_generic_controllers");
const account_controller_1 = require("./account_controller");
const createRider = async (httpRequest, httpResponse) => (0, _generic_controllers_1.createEntityWithRelation)("account", "rider", httpRequest, httpResponse);
exports.createRider = createRider;
const getRider = async (httpRequest, httpResponse) => (0, _generic_controllers_1.getEntityWithRelation)("account", "rider", httpRequest, httpResponse);
exports.getRider = getRider;
const getFavoriteDrivers = async (httpRequest, httpResponse) => (0, _generic_controllers_1.getEntityWithRelation)("driver", "favorite_driver", httpRequest, httpResponse, "account_id");
exports.getFavoriteDrivers = getFavoriteDrivers;
const updateRider = async (httpRequest, httpResponse) => (0, _generic_controllers_1.updateEntityWithRelation)("account", "rider", httpRequest, httpResponse);
exports.updateRider = updateRider;
exports.deleteRider = account_controller_1.deleteAccount; // Deleting the account will delete the
// rider data too, because a CASCADE constraint is specified on the account_id
// column.
