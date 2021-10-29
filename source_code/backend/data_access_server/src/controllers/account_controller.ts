import { Request, Response } from "express";
import { preventUnauthorizedAccountUpdate } from "../security";
import Controller from "./controller";

export default class AccountController extends Controller {

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
}
