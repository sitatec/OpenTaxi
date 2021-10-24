import { Response } from "express";
import { DatabaseError } from "../db/error";

export const buildInsertQueryFromJSON = (
  tableName: string,
  json: Record<string, unknown>
) => {
  const columnNames = Object.keys(json).join();
  const columnValues = Object.values(json).join();
  return `INSERT INTO ${tableName} (${columnNames}) VALUES (${columnValues})`;
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
