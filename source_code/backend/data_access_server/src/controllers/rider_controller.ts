import { Request, Response } from "express";
import {
  createEntityWithRelation,
  getEntityWithRelation,
  updateEntityWithRelation,
} from "../utils/controller_utils";
import { deleteAccount } from "./account_controller";

export const createRider = async (req: Request, res: Response) =>
  createEntityWithRelation("account", "rider", req, res);

export const getRider = async (req: Request, res: Response) =>
  getEntityWithRelation("account", "rider", req, res);

export const updateRider = async (req: Request, res: Response) =>
  updateEntityWithRelation("account", "rider", req, res);

export const deleteRider = deleteAccount;// Deleting the account will delete the
// rider data too, because a CASCADE constraint is specified on the account_id
// column.
