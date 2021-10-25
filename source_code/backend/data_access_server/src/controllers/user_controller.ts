import { Request, Response } from "express";
import { execQuery } from "../db";
import { isAdminUser } from "../security";
import {
  buildInsertQueryFromJSON,
  buildUpdateQueryFromJSON,
  getColumnById,
  handleDbQueryError,
} from "../utils/database_utils";

/**
 * Create a user, depending the role field it will be a driver, a rider or a admin.
 */
export const createUser = async (req: Request, res: Response) => {
  try {
    const requestBody = JSON.parse(req.body);
    const query = buildInsertQueryFromJSON("user", requestBody);
    await execQuery(query.text, query.paramValues);
    res.send({ status: "success" });
  } catch (error) {
    handleDbQueryError(error, res);
  }
};

export const getUser = async (req: Request, res: Response) => {
  try {
    const user = await getColumnById(req.params.id as string | number, "user");
    if (!user) {
      res.status(404).send(`User with id = ${req.params.id} not found.`);
    } else {
      res.send(user);
    }
  } catch (error) {
    handleDbQueryError(error, res);
  }
};

export const updateUser = async (req: Request, res: Response) => {
  try {
    const requestBody = JSON.parse(req.body);
    delete requestBody.id; // The user id must not be changeable.
    delete requestBody.role; // A user role can't be changed once created;
    if (requestBody.account_status && !(await isAdminUser(res.locals.userId))) {
    // Here we could just check if the user is not an admin and delete the property
    // but the `isAdminUser(...)` function make a db query (wich is relatively a long operation)
    // so we check first if the the `account_status` is part of the field to be updated.
      delete requestBody.account_status; // Only an admin can change the status of an account.
    }
    const query = buildUpdateQueryFromJSON("user", requestBody);
    await execQuery(query.text, query.paramValues);
    res.send({ status: "success" });
  } catch (error) {
    handleDbQueryError(error, res);
  }
};
