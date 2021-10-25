import { Request, Response } from "express";
import { execQueriesInTransaction } from "../db";
import {
  buildInsertQueryFromJSON,
  buildUpdateQueryFromJSON,
  getColumnById,
  getRelationById,
  handleDbQueryError,
} from "./database_utils";
import { sendSuccessResponse } from "./http_utils";
import { JSObject } from "./type_alias";

export const createEntityWithRelation = async (
  parentEntityName: string,
  childEntityName: string,
  req: Request,
  res: Response
) => {
  const data = JSON.parse(req.body);
  const insertParentEntityQuery = buildInsertQueryFromJSON(
    parentEntityName,
    data[parentEntityName]
  );
  const insertChildEntityQuery = buildInsertQueryFromJSON(
    childEntityName,
    data[childEntityName]
  );
  try {
    await execQueriesInTransaction([insertParentEntityQuery, insertChildEntityQuery]);
    sendSuccessResponse(res, 201);
  } catch (error) {
    handleDbQueryError(error, res);
  }
};

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
  parentEntityName: string,
  childEntityName: string,
  req: Request,
  res: Response
) => {
  wrappeResponseHandling(parentEntityName, req.params.id, res, async () => {
    return getRelationById(req.params.id, parentEntityName, childEntityName);
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

export const updateEntityWithRelation = async (
  parentEntityName: string,
  childEntityName: string,
  req: Request,
  res: Response
) => {
  const data = JSON.parse(req.body);
  const updateParentEntityQuery = buildUpdateQueryFromJSON(
    parentEntityName,
    data[parentEntityName],
    req.params.id
  );
  const updateChildEntityQuery = buildUpdateQueryFromJSON(
    childEntityName,
    data[childEntityName],
    req.params.id
  );

  try {
    await execQueriesInTransaction([updateParentEntityQuery, updateChildEntityQuery]);
    sendSuccessResponse(res);
  } catch (error) {
    handleDbQueryError(error, res);
  }
};
