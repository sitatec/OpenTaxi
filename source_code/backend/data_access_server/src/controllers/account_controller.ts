import { Request, Response } from "express";
import { preventUnauthorizedAccountUpdate } from "../security";
import {
  createEntity,
  deleteEntity,
  getEntity,
  updateEntity,
} from "../controllers/_generic_controllers";

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
  const requestBody = httpRequest.body;
  preventUnauthorizedAccountUpdate(requestBody, httpResponse.locals.userId);
  return updateEntity("account", httpRequest, httpResponse, requestBody);
};

export const deleteAccount = async (
  httpRequest: Request,
  httpResponse: Response
) => deleteEntity("account", httpRequest, httpResponse);
