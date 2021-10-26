import { Response } from "express";
import { execQuery } from "../db";
import { DatabaseError } from "../db/error";
import { JSObject, Pair, Query } from "../types";

type DbQueryColumnsAndParams = {
  names: string;
  params: string;
  paramValues: (string | number)[];
};

export const buildInsertQueryFromJSON = (
  tableName: string,
  json: JSObject
): Query => {
  const columns = extractColumnNameAndValuesFromJSON(json);
  return {
    text: `INSERT INTO ${tableName} (${columns.names}) VALUES (${columns.params})`,
    paramValues: columns.paramValues,
  };
};

export const buildUpdateQueryFromJSON = (
  tableName: string,
  json: JSObject,
  rowId: string
): Query => {
  const columns = extractColumnNameAndValuesFromJSON(json);
  return {
    text: `UPDATE ${tableName} SET (${columns.names}) = (${columns.params}) 
    WHERE id = '${rowId}'`,
    paramValues: columns.paramValues,
  };
};

const extractColumnNameAndValuesFromJSON = (json: JSObject): DbQueryColumnsAndParams => {
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
    throw error;
  }
};

export const getRowByColumns = async (
  columns: Pair<string, string>[],
  table: string
): Promise<JSObject> => {
  const columnNamesAndParams = getColumnNamesAndParams(columns);
  const result = await execQuery(
    `SELECT * FROM ${table} WHERE ${columnNamesAndParams.first}`,
    columnNamesAndParams.second
  );
  return result[0];
};

const getColumnNamesAndParams = (
  columns: Pair<string, string | number>[]
): Pair<string, (string | number)[]> => {
  let i = 1;
  let columnNamesAndParams = "";
  let columnParamValues = [];
  for (const colum of columns) {
    columnNamesAndParams += `${colum.first} = $${i++}`;
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
export const getRelationByColumns = async (
  columns: Pair<string, string | number>[],
  parentTable: string,
  childTable: string
): Promise<JSObject> => {
  const columnNamesAndParams = getColumnNamesAndParams(columns);
  const queryResult = await execQuery(
    `SELECT * FROM ${parentTable} 
    JOIN ${childTable} ON ${parentTable}.id = ${childTable}.${parentTable}_id 
    WHERE ${columnNamesAndParams.first}`,
    columnNamesAndParams.second
  );
  return queryResult[0];
};
