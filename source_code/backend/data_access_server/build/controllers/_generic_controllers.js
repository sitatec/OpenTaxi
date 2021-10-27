"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteEntity = exports.updateEntityWithRelation = exports.updateEntity = exports.getEntityWithRelation = exports.getEntity = exports.createEntityWithRelation = exports.createEntity = void 0;
const db_1 = require("../db");
const types_1 = require("../types");
const controller_utils_1 = require("../utils/controller_utils");
const database_utils_1 = require("../utils/database_utils");
const http_utils_1 = require("../utils/http_utils");
// ---------------------- CREATE ---------------------- //
const createEntity = async (entityName, httpRequest, httpResponse) => {
    try {
        const query = (0, database_utils_1.buildInsertQueryFromJSON)(entityName, httpRequest.body);
        const queryResult = await (0, db_1.execQuery)(query.text, query.paramValues);
        (0, http_utils_1.sendSuccessResponse)(httpResponse, 201, queryResult.rowCount);
    }
    catch (error) {
        (0, database_utils_1.handleDbQueryError)(error, httpResponse);
    }
};
exports.createEntity = createEntity;
const createEntityWithRelation = async (parentEntityName, childEntityName, httpRequest, httpResponse) => {
    const data = httpRequest.body;
    const insertParentEntityQuery = (0, database_utils_1.buildInsertQueryFromJSON)(parentEntityName, data[parentEntityName]);
    const insertChildEntityQuery = (0, database_utils_1.buildInsertQueryFromJSON)(childEntityName, data[childEntityName]);
    try {
        await (0, db_1.execQueriesInTransaction)([
            insertParentEntityQuery,
            insertChildEntityQuery,
        ]);
        (0, http_utils_1.sendSuccessResponse)(httpResponse, 201);
    }
    catch (error) {
        (0, database_utils_1.handleDbQueryError)(error, httpResponse);
    }
};
exports.createEntityWithRelation = createEntityWithRelation;
// ---------------------- READ ---------------------- //
const getEntity = async (entityName, httpRequest, httpResponse) => {
    const queryParams = (0, http_utils_1.getQueryParams)(httpRequest);
    if (queryParams.length === 0) {
        return httpResponse.status(400).end();
    }
    return (0, controller_utils_1.wrappeResponseHandling)(entityName, queryParams, httpResponse, async () => {
        return (0, database_utils_1.getRowByColumns)(queryParams, entityName);
    });
};
exports.getEntity = getEntity;
const getEntityWithRelation = async (parentEntityName, childEntityName, httpRequest, httpResponse, parentTablePrimaryKey = "id") => {
    const queryParams = (0, http_utils_1.getQueryParams)(httpRequest);
    if (!queryParams) {
        return httpResponse.status(400).end();
    }
    return (0, controller_utils_1.wrappeResponseHandling)(childEntityName, queryParams, httpResponse, async () => {
        return (0, database_utils_1.getRelationByColumns)(queryParams, parentEntityName, childEntityName, parentTablePrimaryKey);
    });
};
exports.getEntityWithRelation = getEntityWithRelation;
async function updateEntity(entityName, httpRequest, httpResponse, data) {
    if (!data) {
    }
    const entityId = httpRequest.params.id;
    const query = (0, database_utils_1.buildUpdateQueryFromJSON)(entityName, httpRequest.body, entityId);
    return (0, controller_utils_1.wrappeResponseHandling)(entityName, [new types_1.Pair("id", entityId)], httpResponse, async () => {
        return (await (0, db_1.execQuery)(query.text, query.paramValues)).rowCount;
    });
}
exports.updateEntity = updateEntity;
const updateEntityWithRelation = async (parentEntityName, childEntityName, httpRequest, httpResponse) => {
    const entityId = httpRequest.params.id;
    const data = httpRequest.body;
    const updateParentEntityQuery = (0, database_utils_1.buildUpdateQueryFromJSON)(parentEntityName, data[parentEntityName], httpRequest.params.id);
    const updateChildEntityQuery = (0, database_utils_1.buildUpdateQueryFromJSON)(childEntityName, data[childEntityName], httpRequest.params.id);
    return (0, controller_utils_1.wrappeResponseHandling)(childEntityName, [new types_1.Pair("id", entityId)], httpResponse, async () => {
        return (await (0, db_1.execQueriesInTransaction)([
            updateParentEntityQuery,
            updateChildEntityQuery,
        ])).rowCount;
    });
};
exports.updateEntityWithRelation = updateEntityWithRelation;
// ---------------------- DELETE ---------------------- //
const deleteEntity = async (entityName, httpRequest, httpResponse) => {
    const entityId = httpRequest.params.id;
    return (0, controller_utils_1.wrappeResponseHandling)(entityName, [new types_1.Pair("id", entityId)], httpResponse, async () => {
        return (await (0, db_1.execQuery)("DELETE FROM account WHERE id = $1", [entityId])).rowCount;
    });
};
exports.deleteEntity = deleteEntity;
