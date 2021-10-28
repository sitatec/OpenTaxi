import { Request, Response } from "express";
import {
  createEntity,
  createEntityWithRelation,
  getEntityWithRelation,
  updateEntity,
  updateEntityWithRelation,
} from "../controllers/_generic_controllers";
import { execQuery } from "../db";
import { wrappeResponseHandling } from "../utils/controller_utils";
import { getColumnNamesAndParams } from "../utils/database_utils";
import { getQueryParams } from "../utils/http_utils";
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
    "account_id",
    "driver_id",
    "driver"
  );

export const addFavoriteDriver = async (
  httpRequest: Request,
  httpResponse: Response
) => {
  httpRequest.body = httpRequest.query
  return createEntity("favorite_driver", httpRequest, httpResponse);
}

export const deleteFavoriteDriver = async (
  httpRequest: Request,
  httpResponse: Response
) => {
  const queryParams = getQueryParams(httpRequest);
  if (queryParams.length === 0) {
    return httpResponse.status(400).end();
  }
  const columnNamesAndParams = getColumnNamesAndParams(
    queryParams,
    "favorite_driver"
  );

  wrappeResponseHandling(
    "favorite_driver",
    queryParams,
    httpResponse,
    async () => {
      return (
        await execQuery(
          `DELETE FROM favorite_driver WHERE ${columnNamesAndParams.first}`,
          columnNamesAndParams.second
        )
      ).rowCount;
    }
  );
};

export const updateRider = async (
  httpRequest: Request,
  httpResponse: Response
) => {
  if (httpRequest.body.account) {
    return updateEntityWithRelation(
      "account",
      "rider",
      httpRequest,
      httpResponse
    );
  } else {
    return updateEntity("rider", httpRequest, httpResponse);
  }
};

export const deleteRider = deleteAccount; // Deleting the account will delete the
// rider data too, because a CASCADE constraint is specified on the account_id
// column.
