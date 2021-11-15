import { Request, Response } from "express";
import { preventUnauthorizedAccountUpdate } from "../security";
import { wrappeResponseHandling } from "../utils/controller_utils";
import { getColumnNamesAndParams } from "../utils/database_utils";
import { getQueryParams } from "../utils/http_utils";
import Controller from "./controller";

export default class AccountController extends Controller {
  // TODO refactor, add create, get, update, delete... methods in `Controller`
  // and just pass the entity name to the Controller's constructor.
  createAccount = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntity("account", httpRequest, httpResponse);

  getAccount = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("account", httpRequest, httpResponse);

  updateAccount = async (httpRequest: Request, httpResponse: Response) => {
    preventUnauthorizedAccountUpdate(
      httpRequest.body,
      httpResponse.locals.userId
    );
    return this.entityManager.updateEntity(
      "account",
      httpRequest,
      httpResponse
    );
  };

  deleteAccount = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("account", httpRequest, httpResponse);

  getNotificationToken = async (
    httpRequest: Request,
    httpResponse: Response
  ) => {
    const queryParams = getQueryParams(httpRequest);
    if (queryParams.length === 0) {
      return httpResponse.status(400).end();
    }
    const columnNamesAndParams = getColumnNamesAndParams(
      queryParams,
      "account"
    );

    wrappeResponseHandling("account", queryParams, httpResponse, async () => {
      return (
        await this.entityManager.execCustomQuery(
          `SELECT account.notification_token FROM account WHERE ${columnNamesAndParams.first}`,
          columnNamesAndParams.second
        )
      ).rows[0];
    });
  };
}
