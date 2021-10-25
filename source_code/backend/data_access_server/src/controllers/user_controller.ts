import { Request, Response } from "express";
import { DatabaseError } from "../db/error";
import { beginTransaction, execQuery } from "../db";
import { buildInsertQueryFromJSON, getColumnById, handleDbQueryError } from "../utils/database_utils";

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

export const getUser = async (req: Request, res: Response) => {
  try {
    const user = await getColumnById(req.query.id as string | number, "user");
    if(!user){
      res.status(404).send(`User with id = ${req.query.id} not found.`)
    } else {
      res.send(user);
    }
  } catch (error) {
    handleDbQueryError(error, res);
  }
}