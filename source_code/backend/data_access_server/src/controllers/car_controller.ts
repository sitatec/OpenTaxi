import { Request, Response } from "express";
import {
  createEntity,
  deleteEntity,
  getEntity,
  updateEntity,
} from "./_generic_controllers";

export const createCar = async (
  httpRequest: Request,
  httpResponse: Response
) => createEntity("car", httpRequest, httpResponse);

export const getCar = (httpRequest: Request, httpResponse: Response) =>
  getEntity("car", httpRequest, httpResponse);

export const updateCar = async (
  httpRequest: Request,
  httpResponse: Response
) => updateEntity("car", httpRequest, httpResponse);

export const deleteCar = async (
  httpRequest: Request,
  httpResponse: Response
) => deleteEntity("car", httpRequest, httpResponse);
