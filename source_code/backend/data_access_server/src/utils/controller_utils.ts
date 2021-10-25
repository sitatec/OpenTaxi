import { Request, Response } from "express";
import {
  getColumnById,
  getRelationById,
  handleDbQueryError,
} from "./database_utils";
import { JSObject } from "./type_alias";

export const getEntity = async (
  entityName: string,
  req: Request,
  res: Response
) => {
  wrappeResponseHandling(entityName, req.params.id, res, async () => {
    return getColumnById(req.params.id as string | number, entityName);
  });
};

export const getEntityWithRelation = async (
  parentEntity: string,
  childEntity: string,
  req: Request,
  res: Response
) => {
  wrappeResponseHandling(parentEntity, req.params.id, res, async () => {
    return getRelationById(req.params.id, parentEntity, childEntity);
  });
};

export const wrappeResponseHandling = async (
  entityName: string,
  id: string,
  res: Response,
  fn: () => Promise<JSObject>
) => {
  try {
    const result = await fn();
    if (!result) {
      res.status(404).send({
        message: `${entityName} with id = ${id} not found.`,
        status: "failure",
      });
    } else {
      res.status(200).send({ data: result, status: "success" });
    }
  } catch (error) {
    handleDbQueryError(error, res);
  }
};
