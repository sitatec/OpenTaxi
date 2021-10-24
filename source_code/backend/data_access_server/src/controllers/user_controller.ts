import { Request, Response } from "express";
import { DatabaseError } from "../db/error";
import { beginTransaction, execQuery } from "../db";
import { buildInsertQueryFromJSON, handleDbQueryError } from "../utils/database_utils";

/**
 * Create a user, depending the role field it will be a driver, a rider or a admin.
 */
export const createUser = async (req: Request, res: Response) => {
  try {
    const requestBody = JSON.parse(req.body);
    await execQuery(buildInsertQueryFromJSON("user", requestBody));
    res.send({ status: "success" });
  } catch (error) {
    handleDbQueryError(error, res);
  }
};
