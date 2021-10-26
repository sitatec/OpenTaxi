import { Request, Response } from "express";
import {
  createEntityWithRelation,
  getEntityWithRelation,
  updateEntityWithRelation,
} from "../controllers/_generic_controllers";
import { deleteAccount } from "./account_controller";

export const createRider = async (
  httpRequest: Request,
  httpResponse: Response
) => createEntityWithRelation("account", "rider", httpRequest, httpResponse);

export const getRider = async (httpRequest: Request, httpResponse: Response) =>
  getEntityWithRelation("account", "rider", httpRequest, httpResponse);

export const getFavoriteDrivers = async (
  httpRequest: Request,
  httpResponse: Response
) =>
  getEntityWithRelation(
    "driver",
    "favorite_driver",
    httpRequest,
    httpResponse,
    "account_id"
  );

export const updateRider = async (
  httpRequest: Request,
  httpResponse: Response
) => updateEntityWithRelation("account", "rider", httpRequest, httpResponse);

export const deleteRider = deleteAccount; // Deleting the account will delete the
// rider data too, because a CASCADE constraint is specified on the account_id
// column.
