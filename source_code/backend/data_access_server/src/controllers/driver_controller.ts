import { Request, Response } from "express";
import { beginTransaction } from "../db";
import {
  buildInsertQueryFromJSON,
  handleDbQueryError,
} from "../utils/database_utils";

export const createDriver = async (req: Request, res: Response) => {
  const driverData = JSON.parse(req.body);
  const insertUserQuery = buildInsertQueryFromJSON("user", driverData.user);
  const insertDriverQuery = buildInsertQueryFromJSON("driver", driverData.user);
  const dbTransactionClient = await beginTransaction();
  if (dbTransactionClient == undefined) {
    res.status(500).end();
  }
  try {
    await dbTransactionClient.query(insertUserQuery);
    await dbTransactionClient.query(insertDriverQuery);
    await dbTransactionClient.query("COMMIT");
  } catch (error) {
    await dbTransactionClient.query("ROLLBACK");
    handleDbQueryError(error, res);
  } finally {
    dbTransactionClient.release();
  }
};
