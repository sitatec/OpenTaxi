import { Request, Response } from "express";
import { preventUnauthorizedAccountUpdate } from "../security";

export const createAccount = async (
  httpRequest: Request,
  httpResponse: Response
) => createEntity("account", httpRequest, httpResponse);

export const getAccount = (httpRequest: Request, httpResponse: Response) =>
  getEntity("account", httpRequest, httpResponse);

export const updateAccount = async (
  httpRequest: Request,
  httpResponse: Response
) => {
  preventUnauthorizedAccountUpdate(httpRequest.body, httpResponse.locals.userId);
  return updateEntity("account", httpRequest, httpResponse);
};

export const deleteAccount = async (
  httpRequest: Request,
  httpResponse: Response
) => deleteEntity("account", httpRequest, httpResponse);
