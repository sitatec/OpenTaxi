"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.wrappeResponseHandling = void 0;
const database_utils_1 = require("./database_utils");
const http_utils_1 = require("./http_utils");
const wrappeResponseHandling = async (entityName, queryParams, httpResponse, fn) => {
    try {
        const result = await fn();
        if (result) {
            (0, http_utils_1.sendSuccessResponse)(httpResponse, 200, result);
        }
        else {
            httpResponse.status(404).send({
                message: `${entityName} with ${queryParams.join(" & ")} not found.`,
                status: "failure",
            });
        }
    }
    catch (error) {
        (0, database_utils_1.handleDbQueryError)(error, httpResponse);
    }
};
exports.wrappeResponseHandling = wrappeResponseHandling;
