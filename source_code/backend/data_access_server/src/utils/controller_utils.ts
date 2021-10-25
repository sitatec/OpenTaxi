import { Request, response, Response } from "express";
import { execQueriesInTransaction } from "../db";
import {
  buildInsertQueryFromJSON,
  buildUpdateQueryFromJSON,
  getRowByColumn,
  getRelationByColumn,
  handleDbQueryError,
} from "./database_utils";
import { sendSuccessResponse } from "./http_utils";
import { JSObject, Pair } from "../types";

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
    await execQueriesInTransaction([
      insertParentEntityQuery,
      insertChildEntityQuery,
    ]);
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
  const queryParam = getQueryParam(req);
  if (!queryParam) {
    return res.status(400).end();
  }
  wrappeResponseHandling(entityName, queryParam, res, async () => {
    return getRowByColumn(queryParam.first, queryParam.second, entityName);
  });
};

const getQueryParam = (req: Request): Pair<string, string> | null => {
  const queryParams = req.query;
  if (queryParams.id) {
    return {
      first: "id",
      second: queryParams.id as string,
    };
  } else if (queryParams.email) {
    return {
      first: "email",
      second: queryParams.email as string,
    };
  } else if (queryParams.phone) {
    return {
      first: "phone_number",
      second: queryParams.phone as string,
    };
  } else return null;
};

export const getEntityWithRelation = async (
  parentEntityName: string,
  childEntityName: string,
  req: Request,
  res: Response
) => {
  const queryParam = getQueryParam(req);
  if (!queryParam) {
    return res.status(400).end();
  }
  wrappeResponseHandling(parentEntityName, queryParam, res, async () => {
    return getRelationByColumn(
      queryParam.first,
      queryParam.second,
      parentEntityName,
      childEntityName
    );
  });
};

export const wrappeResponseHandling = async (
  entityName: string,
  queryParam: Pair<string, string>,
  res: Response,
  fn: () => Promise<JSObject>
) => {
  try {
    const result = await fn();
    if (!result) {
      res.status(404).send({
        message: `${entityName} with ${queryParam.first} = ${queryParam.second} not found.`,
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
    await execQueriesInTransaction([
      updateParentEntityQuery,
      updateChildEntityQuery,
    ]);
    sendSuccessResponse(res);
  } catch (error) {
    handleDbQueryError(error, res);
  }
};
