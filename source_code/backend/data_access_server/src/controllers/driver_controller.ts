import { query, Request, Response } from "express";
import { beginTransaction, execQueriesInTransaction } from "../db";
import { getEntityWithRelation } from "../utils/controller_utils";
import {
  buildInsertQueryFromJSON,
  buildUpdateQueryFromJSON,
  getRelationById,
  handleDbQueryError,
} from "../utils/database_utils";
import { deleteAccount } from "./account_controller";

export const createDriver = async (req: Request, res: Response) => {
  const driverData = JSON.parse(req.body);
  const insertAccountQuery = buildInsertQueryFromJSON(
    "account",
    driverData.user
  );
  const insertDriverQuery = buildInsertQueryFromJSON(
    "driver",
    driverData.driver
  );
  try {
    await execQueriesInTransaction([insertAccountQuery, insertDriverQuery]);
    res.locals.sendSuccessResponse(201);
  } catch (error) {
    handleDbQueryError(error, res);
  }
};

export const getDriver = async (req: Request, res: Response) =>
  getEntityWithRelation("account", "driver", req, res);

export const updateDriver = async (req: Request, res: Response) => {
  const requestData = JSON.parse(req.body);
  const updateAccountQuery = buildUpdateQueryFromJSON(
    "account",
    requestData.account,
    req.params.id
  );
  const updateDriverQuery = buildUpdateQueryFromJSON(
    "driver",
    requestData.driver,
    req.params.id
  );

  try {
    await execQueriesInTransaction([updateAccountQuery, updateDriverQuery]);
    res.locals.sendSuccessResponse();
  } catch (error) {
    handleDbQueryError(error, res);
  }
};

export const deleteDriver = deleteAccount; // Deleting the account will delete the
// driver data too, because a CASCADE constraint is specified on the account_id
// column.
