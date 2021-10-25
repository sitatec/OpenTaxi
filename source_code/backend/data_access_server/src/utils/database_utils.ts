import { Response } from "express";
import { execQuery } from "../db";
import { DatabaseError } from "../db/error";
import { JSObject, Query } from "../types";

type DbColumns = {
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
    text: `UPDATE ${tableName} SET (${columns.names}) = (${columns.params}) WHERE id = '${rowId}'`,
    paramValues: columns.paramValues,
  };
};

const extractColumnNameAndValuesFromJSON = (json: JSObject): DbColumns => {
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

export const handleDbQueryError = (error: unknown, res: Response) => {
  if (error instanceof DatabaseError) {
    let statusCode = 400;
    if (error.name == "unknown") {
      statusCode = 500;
    }
    res
      .status(statusCode)
      .send({ message: error.message, code: error.code, status: "failure" });
  } else {
    throw error;
  }
};

export const getRowByColumn = async (
  columnName: string,
  columnValue: string | number,
  table: string
): Promise<JSObject> => {
  const columns = await execQuery(
    `SELECT * FROM ${table} WHERE ${columnName} = $1`,
    [columnValue]
  );
  return columns[0];
};

/**
 * Return the data of the relation formed by the given`parentTable` and `childTable`
 *  arguments where the given `columnName` =`columnValue` in the `parentTable`.
 */
export const getRelationByColumn = async (
  columnName: string,
  columnValue: string | number,
  parentTable: string,
  childTable: string
): Promise<JSObject> => {
  const queryResult = await execQuery(
    `SELECT * FROM ${parentTable} JOIN ${childTable} ON ${parentTable}.id = ${childTable}.${parentTable}_id WHERE ${parentTable}.${columnName} = ${columnValue}`
  );
  return queryResult[0];
};
