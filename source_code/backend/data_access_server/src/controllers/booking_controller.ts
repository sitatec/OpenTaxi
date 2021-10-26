import { Request, Response } from "express";
import {
  createEntity,
  deleteEntity,
  getEntity,
  updateEntity,
} from "./_generic_controllers";

export const createBooking = async (
  httpRequest: Request,
  httpResponse: Response
) => createEntity("booking", httpRequest, httpResponse);

export const getBooking = (httpRequest: Request, httpResponse: Response) =>
  getEntity("booking", httpRequest, httpResponse);

export const updateBooking = async (
  httpRequest: Request,
  httpResponse: Response
) => updateEntity("booking", httpRequest, httpResponse);

export const deleteBooking = async (
  httpRequest: Request,
  httpResponse: Response
) => deleteEntity("booking", httpRequest, httpResponse);