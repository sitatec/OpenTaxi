import { Request, Response } from "express";
import Controller from "./controller";

export default class DriverController extends Controller {
  createDriver = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntityWithRelation(
      "account",
      "driver",
      httpRequest,
      httpResponse
    );

  getDriver = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntityWithRelation(
      "account",
      "driver",
      httpRequest,
      httpResponse
    );

  getDriverData = (httpRequest: Request, httpResponse: Response) => 
  this.entityManager.getEntity("driver", httpRequest, httpResponse);

  updateDriver = (httpRequest: Request, httpResponse: Response) => {
    if (httpRequest.body.account) {
      return this.entityManager.updateEntityWithRelation(
        "account",
        "driver",
        httpRequest,
        httpResponse
      );
    } else {
      return this.entityManager.updateEntity(
        "driver",
        httpRequest,
        httpResponse
      );
    }
  };

  deleteDriver = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("account", httpRequest, httpResponse); // Deleting the account will delete the
  // driver data too, because a CASCADE constraint is specified on the account_id
  // column.
}
