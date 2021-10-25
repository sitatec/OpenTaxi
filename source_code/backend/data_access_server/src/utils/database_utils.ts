import { Response } from "express";
import { execQuery } from "../db";
import { DatabaseError } from "../db/error";
import { JSObject } from "./type_alias";

interface Query {
  text: string;
  params: Array<number | string>;
}

export const buildInsertQueryFromJSON = (tableName: string, json: JSObject) => {
  const columnNames = Object.keys(json).join();
  const columnValues = Object.values(json).join();
  return `INSERT INTO ${tableName} (${columnNames}) VALUES (${columnValues})`;
};

export const buildUpdateQueryFromJSON = (
  tableName: string,
  json: JSObject
): Query => {
  const columnNames = Object.keys(json).join();
  const columnValues = Object.values(json);
  let columnParams = "";

  for (let i = 1; i < columnValues.length; i++) {
    columnParams += `$${i},`;
  }
  columnParams += `$${columnValues.length}`; // Add the last element without comma at the end.

  return {
    text: `UPDATE ${tableName} SET (${columnNames}) = (${columnParams})`,
    params: columnValues as (number | string)[],
  };
};

export const handleDbQueryError = (error: unknown, res: Response) => {
  if (error instanceof DatabaseError) {
    let statusCode = 400;
    if (error.name == "unknown") {
      statusCode = 500;
    }
    res.status(statusCode).send(error.message);
  } else {
    throw error;
  }
};

export const getColumnById = async (
  id: string | number,
  table: string
): Promise<JSObject> => {
  const columns = await execQuery(`SELECT * FROM ${table} WHERE id = $1`, [id]);
  return columns[0];
};
