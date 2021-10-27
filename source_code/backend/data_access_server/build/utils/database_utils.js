"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getRelationByColumns = exports.getRowByColumns = exports.handleDbQueryError = exports.buildUpdateQueryFromJSON = exports.buildInsertQueryFromJSON = void 0;
const db_1 = require("../db");
const error_1 = require("../db/error");
const buildInsertQueryFromJSON = (tableName, json) => {
    const columns = extractColumnNameAndValuesFromJSON(json);
    return {
        text: `INSERT INTO ${tableName} (${columns.names}) VALUES (${columns.params})`,
        paramValues: columns.paramValues,
    };
};
exports.buildInsertQueryFromJSON = buildInsertQueryFromJSON;
const buildUpdateQueryFromJSON = (tableName, json, rowId) => {
    const columns = extractColumnNameAndValuesFromJSON(json);
    return {
        text: `UPDATE ${tableName} SET (${columns.names}) = (${columns.params}) 
    WHERE id = '${rowId}'`,
        paramValues: columns.paramValues,
    };
};
exports.buildUpdateQueryFromJSON = buildUpdateQueryFromJSON;
const extractColumnNameAndValuesFromJSON = (json) => {
    const columnNames = Object.keys(json).join();
    const columnValues = Object.values(json);
    let columnParams = "";
    for (let i = 1; i < columnValues.length; i++) {
        columnParams += `$${i},`;
    }
    columnParams += `$${columnValues.length}`; // Add the last element without comma at the end.
    return {
        names: columnNames,
        paramValues: columnValues,
        params: columnParams,
    };
};
const handleDbQueryError = (error, httpResponse) => {
    if (error instanceof error_1.DatabaseError) {
        let statusCode = 400;
        if (error.name == "unknown") {
            statusCode = 500;
        }
        httpResponse
            .status(statusCode)
            .send({ message: error.message, code: error.code, status: "failure" });
    }
    else {
        throw error;
    }
};
exports.handleDbQueryError = handleDbQueryError;
const getRowByColumns = async (columns, table) => {
    const columnNamesAndParams = getColumnNamesAndParams(columns, table);
    const result = await (0, db_1.execQuery)(`SELECT * FROM ${table} WHERE ${columnNamesAndParams.first}`, columnNamesAndParams.second);
    return result.rows[0];
};
exports.getRowByColumns = getRowByColumns;
const getColumnNamesAndParams = (columns, tableName) => {
    let i = 1;
    let columnNamesAndParams = "";
    let columnParamValues = [];
    for (const colum of columns) {
        columnNamesAndParams += `${tableName}.${colum.first} = $${i++}`;
        if (i < columns.length) {
            columnNamesAndParams += " AND ";
        }
        columnParamValues.push(colum.second);
    }
    return {
        first: columnNamesAndParams,
        second: columnParamValues,
    };
};
/**
 * Return the data of the relation formed by the given`parentTable` and `childTable`
 *  arguments where the given `columnName` =`columnValue` in the `parentTable`.
 */
const getRelationByColumns = async (columns, parentTable, childTable, parentTablePrimaryKey = "id") => {
    const columnNamesAndParams = getColumnNamesAndParams(columns, childTable);
    const queryResult = await (0, db_1.execQuery)(`SELECT * FROM ${parentTable} 
    JOIN ${childTable} ON ${parentTable}.${parentTablePrimaryKey} = ${childTable}.${parentTable}_${parentTablePrimaryKey}
    WHERE ${columnNamesAndParams.first}`, columnNamesAndParams.second);
    return queryResult.rows[0];
};
exports.getRelationByColumns = getRelationByColumns;
