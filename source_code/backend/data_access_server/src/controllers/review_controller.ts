import { Request, Response } from "express";
import { createEntity, deleteEntity, getEntity, updateEntity } from "./_generic_controllers";

export const createReview = async (
  httpRequest: Request,
  httpResponse: Response
) => createEntity("review", httpRequest, httpResponse);

export const getReview = (httpRequest: Request, httpResponse: Response) =>
  getEntity("review", httpRequest, httpResponse);

export const updateReview = async (
  httpRequest: Request,
  httpResponse: Response
) => updateEntity("review", httpRequest, httpResponse);

export const deleteReview = async (
  httpRequest: Request,
  httpResponse: Response
) => deleteEntity("review", httpRequest, httpResponse);
