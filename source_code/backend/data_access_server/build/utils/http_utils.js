"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getQueryParams = exports.sendSuccessResponse = exports.extractTokenFromHeader = void 0;
const extractTokenFromHeader = (header) => {
    return header.authorization?.replace(RegExp("^Bearers+$"), "");
};
exports.extractTokenFromHeader = extractTokenFromHeader;
function sendSuccessResponse(httpResponse, statusCode, data) {
    if (data) {
        httpResponse.status(statusCode || 200).send({ data: data, status: "success" });
    }
    else {
        httpResponse.status(statusCode || 200).send({ status: "success" });
    }
}
exports.sendSuccessResponse = sendSuccessResponse;
const getQueryParams = (httpRequest) => {
    const queryParams = [];
    for (const [param, paramValue] of Object.entries(httpRequest.query)) {
        queryParams.push({
            first: param,
            second: paramValue,
        });
    }
    return queryParams;
};
exports.getQueryParams = getQueryParams;
