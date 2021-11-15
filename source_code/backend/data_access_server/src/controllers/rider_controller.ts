import { Request, Response } from "express";
import { wrappeResponseHandling } from "../utils/controller_utils";
import { getColumnNamesAndParams } from "../utils/database_utils";
import { getQueryParams } from "../utils/http_utils";
import Controller from "./controller";

export default class RiderController extends Controller {
  createRider = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntityWithRelation(
      "account",
      "rider",
      httpRequest,
      httpResponse
    );

  getRider = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntityWithRelation(
      "account",
      "rider",
      httpRequest,
      httpResponse
    );

  getRiderData = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("rider", httpRequest, httpResponse);

  getFavoriteDrivers = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntityWithRelation(
      "driver",
      "favorite_driver",
      httpRequest,
      httpResponse,
      "account_id",
      "driver_id",
      "driver"
    );

  addFavoriteDriver = async (httpRequest: Request, httpResponse: Response) => {
    httpRequest.body = httpRequest.query;
    return this.entityManager.createEntity(
      "favorite_driver",
      httpRequest,
      httpResponse
    );
  };

  deleteFavoriteDriver = async (
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
          await this.entityManager.execCustomQuery(
            `DELETE FROM favorite_driver WHERE ${columnNamesAndParams.first}`,
            columnNamesAndParams.second
          )
        ).rowCount;
      }
    );
  };

  updateRider = async (httpRequest: Request, httpResponse: Response) => {
    if (httpRequest.body.account) {
      return this.entityManager.updateEntityWithRelation(
        "account",
        "rider",
        httpRequest,
        httpResponse
      );
    } else {
      return this.entityManager.updateEntity(
        "rider",
        httpRequest,
        httpResponse
      );
    }
  };

  deleteRider = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("account", httpRequest, httpResponse); // Deleting the account will delete the
  // rider data too, because a CASCADE constraint is specified on the account_id
  // column.
}
