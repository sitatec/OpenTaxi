import { Request, Response } from "express";
import { execQuery } from "../db";
import { preventUnauthorizedAccountUpdate } from "../security";
import { getEntity } from "../utils/controller_utils";
import {
  buildInsertQueryFromJSON,
  buildUpdateQueryFromJSON,
  getColumnById,
  handleDbQueryError,
} from "../utils/database_utils";

export const createAccount = async (req: Request, res: Response) => {
  try {
    const requestBody = JSON.parse(req.body);
    const query = buildInsertQueryFromJSON("account", requestBody);
    await execQuery(query.text, query.paramValues);
    res.locals.sendSuccessResponse(201);
  } catch (error) {
    handleDbQueryError(error, res);
  }
};

export const getAccount = (req: Request, res: Response) =>
  getEntity("account", req, res);

export const updateAccount = async (req: Request, res: Response) => {
  try {
    const requestBody = JSON.parse(req.body);
    preventUnauthorizedAccountUpdate(requestBody, res.locals.userId);
    const query = buildUpdateQueryFromJSON(
      "account",
      requestBody,
      req.params.id
    );
    await execQuery(query.text, query.paramValues);
    res.locals.sendSuccessResponse();
  } catch (error) {
    handleDbQueryError(error, res);
  }
};

export const deleteAccount = async (req: Request, res: Response) => {
  try {
    const result = await execQuery("DELETE FROM account WHERE id = $1", [
      req.params.id,
    ]);
    if (result.length == 0) {
      res.status(404).send({
        message: `User with id = ${req.params.id} not found.`,
        status: "failure",
      });
    } else {
      res.locals.sendSuccessResponse();
    }
  } catch (error) {
    handleDbQueryError(error, res);
  }
};
