import { Request, Response } from "express";
import { createEntity, deleteEntity, getEntity, updateEntity } from "./_generic_controllers";

export const createPayment = async (
  httpRequest: Request,
  httpResponse: Response
) => createEntity("payment", httpRequest, httpResponse);

export const getPayment = (httpRequest: Request, httpResponse: Response) =>
  getEntity("payment", httpRequest, httpResponse);

export const updatePayment = async (
  httpRequest: Request,
  httpResponse: Response
) => updateEntity("payment", httpRequest, httpResponse);

export const deletePayment = async (
  httpRequest: Request,
  httpResponse: Response
) => deleteEntity("payment", httpRequest, httpResponse);