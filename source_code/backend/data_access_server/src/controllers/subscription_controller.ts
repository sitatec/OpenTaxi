import { Request, Response } from "express";
import {
  createEntity,
  deleteEntity,
  getEntity,
  updateEntity,
} from "./_generic_controllers";

export const createSubscription = async (
  httpRequest: Request,
  httpResponse: Response
) => createEntity("subscription", httpRequest, httpResponse);

export const getSubscription = (httpRequest: Request, httpResponse: Response) =>
  getEntity("subscription", httpRequest, httpResponse);

export const updateSubscription = async (
  httpRequest: Request,
  httpResponse: Response
) => updateEntity("subscription", httpRequest, httpResponse);

export const deleteSubscription = async (
  httpRequest: Request,
  httpResponse: Response
) => deleteEntity("subscription", httpRequest, httpResponse);
