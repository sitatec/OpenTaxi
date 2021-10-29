"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const controller_1 = __importDefault(require("./controller"));
class DriverController extends controller_1.default {
    createDriver(httpRequest, httpResponse) {
        return this.entityManager.createEntityWithRelation("account", "driver", httpRequest, httpResponse);
    }
    getDriver(httpRequest, httpResponse) {
        return this.entityManager.getEntityWithRelation("account", "driver", httpRequest, httpResponse);
    }
    updateDriver(httpRequest, httpResponse) {
        if (httpRequest.body.account) {
            return this.entityManager.updateEntityWithRelation("account", "driver", httpRequest, httpResponse);
        }
        else {
            return this.entityManager.updateEntity("driver", httpRequest, httpResponse);
        }
    }
    deleteDriver(httpRequest, httpResponse) {
        return this.entityManager.deleteEntity("account", httpRequest, httpResponse); // Deleting the account will delete the
        // driver data too, because a CASCADE constraint is specified on the account_id
        // column.
    }
}
exports.default = DriverController;
