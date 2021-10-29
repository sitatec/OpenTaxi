"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getRelationByColumns = exports.getColumnNamesAndParams = exports.getRowByColumns = exports.handleDbQueryError = exports.buildUpdateQueryFromJSON = exports.buildInsertQueryFromJSON = void 0;
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
const buildUpdateQueryFromJSON = (tableName, json, rowId, primaryKeyName = "id") => {
    const columns = extractColumnNameAndValuesFromJSON(json);
    let queryText;
    if (columns.paramValues.length > 1) {
        // If we are updating many column together we must wrappe their names and values with parentheses.
        queryText = `UPDATE ${tableName} SET (${columns.names}) = (${columns.params})`;
    }
    else {
        queryText = `UPDATE ${tableName} SET ${columns.names} = ${columns.params}`;
    }
    return {
        text: `${queryText} WHERE ${primaryKeyName} = ${rowId}`,
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
const getRowByColumns = async (columns, table, db = db_1.Database.instance) => {
    const columnNamesAndParams = (0, exports.getColumnNamesAndParams)(columns, table);
    const result = await db.execQuery(`SELECT * FROM ${table} WHERE ${columnNamesAndParams.first}`, columnNamesAndParams.second);
    return result.rows[0];
};
exports.getRowByColumns = getRowByColumns;
const getColumnNamesAndParams = (columns, tableName) => {
    let i = 1;
    let columnNamesAndParams = "";
    let columnParamValues = [];
    for (const colum of columns) {
        columnNamesAndParams += `${tableName}.${colum.first} = $${i++}`;
        if (i <= columns.length) {
            columnNamesAndParams += " AND ";
        }
        columnParamValues.push(colum.second);
    }
    return {
        first: columnNamesAndParams,
        second: columnParamValues,
    };
};
exports.getColumnNamesAndParams = getColumnNamesAndParams;
/**
 * Return the data of the relation formed by the given`parentTable` and `childTable`
 *  arguments where the given `columnName` =`columnValue` in the `parentTable`.
 */
const getRelationByColumns = async (columns, parentTable, childTable, parentTablePrimaryKey = "id", childTableForeignKey, returnOnlyColunmOfTable = "", db = db_1.Database.instance) => {
    const columnNamesAndParams = (0, exports.getColumnNamesAndParams)(columns, childTable);
    if (!childTableForeignKey) {
        childTableForeignKey = `${parentTable}_${parentTablePrimaryKey}`;
    }
    if (returnOnlyColunmOfTable) {
        returnOnlyColunmOfTable += ".";
    }
    const queryResult = await db.execQuery(`SELECT ${returnOnlyColunmOfTable}* FROM ${parentTable} 
    JOIN ${childTable} ON ${parentTable}.${parentTablePrimaryKey} = ${childTable}.${childTableForeignKey}
    WHERE ${columnNamesAndParams.first}`, columnNamesAndParams.second);
    return queryResult.rows[0];
};
exports.getRelationByColumns = getRelationByColumns;
