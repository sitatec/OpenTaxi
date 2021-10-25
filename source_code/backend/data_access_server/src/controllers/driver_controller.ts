import { Request, Response } from "express";
import {
  createEntityWithRelation,
  getEntityWithRelation,
  updateEntityWithRelation,
} from "../utils/controller_utils";
import { deleteAccount } from "./account_controller";

export const createDriver = async (req: Request, res: Response) =>
  createEntityWithRelation("account", "driver", req, res);

export const getDriver = async (req: Request, res: Response) =>
  getEntityWithRelation("account", "driver", req, res);

export const updateDriver = async (req: Request, res: Response) =>
  updateEntityWithRelation("account", "driver", req, res);

export const deleteDriver = deleteAccount; // Deleting the account will delete the
// driver data too, because a CASCADE constraint is specified on the account_id
// column.
