import { Response } from "express";
import { Database } from "../db";
import { DatabaseError } from "../db/error";
import { JSObject, Pair } from "../types";
import { Query } from "../types/db";
import { handleUnknownError } from "./controller_utils";

type DbQueryColumnsAndParams = {
  names: string;
  params: string;
  paramValues: (string | number)[];
};

export const buildInsertQueryFromJSON = (
  tableName: string,
  json: JSObject,
  returnColumnName?: string
): Query => {
  const columns = extractColumnNameAndValuesFromJSON(json);
  return {
    text: `INSERT INTO ${tableName} (${columns.names}) VALUES (${columns.params}) ${returnColumnName ? 'RETURNING ' + returnColumnName : ''}`,
    paramValues: columns.paramValues,
  };
};

export const buildUpdateQueryFromJSON = (
  tableName: string,
  json: JSObject,
  rowId: string,
  primaryKeyName = "id"
): Query => {
  const columns = extractColumnNameAndValuesFromJSON(json);
  let queryText;
  if (columns.paramValues.length > 1) {
    // If we are updating many column together we must wrappe their names and values with parentheses.
    queryText = `UPDATE ${tableName} SET (${columns.names}) = (${columns.params})`;
  } else {
    queryText = `UPDATE ${tableName} SET ${columns.names} = ${columns.params}`;
  }
  return {
    text: `${queryText} WHERE ${primaryKeyName} = ${rowId}`,
    paramValues: columns.paramValues,
  };
};

const extractColumnNameAndValuesFromJSON = (
  json: JSObject
): DbQueryColumnsAndParams => {
  const columnNames = Object.keys(json).join();
  const columnValues = Object.values(json);
  let columnParams = "";

  for (let i = 1; i < columnValues.length; i++) {
    columnParams += `$${i},`;
  }
  columnParams += `$${columnValues.length}`; // Add the last element without comma at the end.

  return {
    names: columnNames,
    paramValues: columnValues as (string | number)[],
    params: columnParams,
  };
};

export const handleDbQueryError = (error: unknown, httpResponse: Response) => {
  if (error instanceof DatabaseError) {
    let statusCode = 400;
    if (error.name == "unknown") {
      statusCode = 500;
    }
    httpResponse
      .status(statusCode)
      .send({ message: error.message, code: error.code, status: "failure" });
  } else {
    handleUnknownError(error, httpResponse);
  }
};

export const getRowByColumns = async (
  columns: Pair<string, string>[],
  table: string,
  fields: string = "",
  db = Database.initialize()
): Promise<JSObject> => {
  const columnNamesAndParams = getColumnNamesAndParams(columns, table);
  if(fields.length == 0){
    fields = "*";
  }
  const result = await db.execQuery(
    `SELECT ${fields} FROM ${table} WHERE ${columnNamesAndParams.first}`,
    columnNamesAndParams.second
  );
  return result.rows[0];
};

export const getColumnNamesAndParams = (
  columns: Pair<string, string | number>[],
  tableName: string
): Pair<string, (string | number)[]> => {
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

/**
 * Return the data of the relation formed by the given`parentTable` and `childTable`
 *  arguments where the given `columnName` = `columnValue` in the `childTable`.
 */
export const getRelationByColumns = async (
  columns: Pair<string, string | number>[],
  parentTable: string,
  childTable: string,
  parentTablePrimaryKey: string = "id",
  childTableForeignKey?: string,
  returnOnlyColunmOfTable = "",
  db = Database.initialize()
): Promise<JSObject> => {
  const columnNamesAndParams = getColumnNamesAndParams(columns, childTable);
  if(!childTableForeignKey){
    childTableForeignKey = `${parentTable}_${parentTablePrimaryKey}`;
  }
  if(returnOnlyColunmOfTable) {
    returnOnlyColunmOfTable += ".";
  }
  const queryResult = await db.execQuery(
    `SELECT ${returnOnlyColunmOfTable}* FROM ${parentTable} 
    JOIN ${childTable} ON ${parentTable}.${parentTablePrimaryKey} = ${childTable}.${childTableForeignKey}
    WHERE ${columnNamesAndParams.first}`,
    columnNamesAndParams.second
  );
  return queryResult.rows[0];
};
