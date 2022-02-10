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

  getFavoriteDrivers = async (httpRequest: Request, httpResponse: Response) => {
    const riderId = httpRequest.query.rider_id;
    const driverId = httpRequest.query.driver_id;

    let queryText =
      "SELECT account.display_name, account.first_name, account.last_name, account.profile_picture_url, driver.online_status, driver.price_by_km FROM favorite_driver JOIN driver ON driver.account_id = favorite_driver.driver_id JOIN account ON account.id = driver.account_id WHERE favorite_driver.rider_id = $1";
    let queryParams = [riderId];

    if (driverId) {
      queryText += " AND favorite_driver.driver_id = $2";
      queryParams.push(driverId);
    }
    
    wrappeResponseHandling(
      "favorite_driver",
      getQueryParams(httpRequest),
      httpResponse,
      async () => {
        return (
          await this.entityManager.execCustomQuery(
            queryText,
            queryParams as string[]
          )
        ).rows;
      }
    );
  };

  addFavoriteDriver = async (httpRequest: Request, httpResponse: Response) => {
    httpRequest.body = httpRequest.query;
    return this.entityManager.createEntity(
      "favorite_driver",
      httpRequest,
      httpResponse,
      ""
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

  addFavoritePlace = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntity(
      "favorite_place",
      httpRequest,
      httpResponse
    );

  getFavoritePlace = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("favorite_place", httpRequest, httpResponse);

  updateFavoritePlace = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.updateEntity(
      "favorite_place",
      httpRequest,
      httpResponse
    );

  deleteFavoritePlace = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity(
      "favorite_place",
      httpRequest,
      httpResponse
    );
}
