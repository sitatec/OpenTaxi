import { Request, Response } from "express";
import {
  createEntity,
  deleteEntity,
  getEntity,
  updateEntity,
} from "./_generic_controllers";

export const createTrip = async (
  httpRequest: Request,
  httpResponse: Response
) => createEntity("trip", httpRequest, httpResponse);

export const getTrip = (httpRequest: Request, httpResponse: Response) =>
  getEntity("trip", httpRequest, httpResponse);

export const updateTrip = async (
  httpRequest: Request,
  httpResponse: Response
) => updateEntity("trip", httpRequest, httpResponse);

export const deleteTrip = async (
  httpRequest: Request,
  httpResponse: Response
) => deleteEntity("trip", httpRequest, httpResponse);
