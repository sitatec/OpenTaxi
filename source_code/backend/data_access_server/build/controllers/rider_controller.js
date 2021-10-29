"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const controller_utils_1 = require("../utils/controller_utils");
const database_utils_1 = require("../utils/database_utils");
const http_utils_1 = require("../utils/http_utils");
const controller_1 = __importDefault(require("./controller"));
class RiderController extends controller_1.default {
    constructor() {
        super(...arguments);
        this.createRider = async (httpRequest, httpResponse) => this.entityManager.createEntityWithRelation("account", "rider", httpRequest, httpResponse);
        this.getRider = async (httpRequest, httpResponse) => this.entityManager.getEntityWithRelation("account", "rider", httpRequest, httpResponse);
        this.getFavoriteDrivers = async (httpRequest, httpResponse) => this.entityManager.getEntityWithRelation("driver", "favorite_driver", httpRequest, httpResponse, "account_id", "driver_id", "driver");
        this.addFavoriteDriver = async (httpRequest, httpResponse) => {
            httpRequest.body = httpRequest.query;
            return this.entityManager.createEntity("favorite_driver", httpRequest, httpResponse);
        };
        this.deleteFavoriteDriver = async (httpRequest, httpResponse) => {
            const queryParams = (0, http_utils_1.getQueryParams)(httpRequest);
            if (queryParams.length === 0) {
                return httpResponse.status(400).end();
            }
            const columnNamesAndParams = (0, database_utils_1.getColumnNamesAndParams)(queryParams, "favorite_driver");
            (0, controller_utils_1.wrappeResponseHandling)("favorite_driver", queryParams, httpResponse, async () => {
                return (await this.entityManager.execCustomQuery(`DELETE FROM favorite_driver WHERE ${columnNamesAndParams.first}`, columnNamesAndParams.second)).rowCount;
            });
        };
        this.updateRider = async (httpRequest, httpResponse) => {
            if (httpRequest.body.account) {
                return this.entityManager.updateEntityWithRelation("account", "rider", httpRequest, httpResponse);
            }
            else {
                return this.entityManager.updateEntity("rider", httpRequest, httpResponse);
            }
        };
        this.deleteRider = async (httpRequest, httpResponse) => this.entityManager.deleteEntity("account", httpRequest, httpResponse); // Deleting the account will delete the
        // rider data too, because a CASCADE constraint is specified on the account_id
        // column.
    }
}
exports.default = RiderController;
