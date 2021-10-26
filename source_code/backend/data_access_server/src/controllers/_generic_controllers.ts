import { Request, Response } from "express";
import { execQueriesInTransaction, execQuery } from "../db";
import { JSObject } from "../types";
import { wrappeResponseHandling } from "../utils/controller_utils";
import {
  buildInsertQueryFromJSON,
  buildUpdateQueryFromJSON,
  getRelationByColumns,
  getRowByColumns,
  handleDbQueryError,
} from "../utils/database_utils";
import { getQueryParams, sendSuccessResponse } from "../utils/http_utils";

// ---------------------- CREATE ---------------------- //

export const createEntity = async (
  entityName: string,
  httpRequest: Request,
  httpResponse: Response
) => {
  try {
    const requestBody = JSON.parse(httpRequest.body);
    const query = buildInsertQueryFromJSON(entityName, requestBody);
    await execQuery(query.text, query.paramValues);
    sendSuccessResponse(httpResponse, 201);
  } catch (error) {
    handleDbQueryError(error, httpResponse);
  }
};

export const createEntityWithRelation = async (
  parentEntityName: string,
  childEntityName: string,
  httpRequest: Request,
  httpResponse: Response
) => {
  const data = JSON.parse(httpRequest.body);
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
    sendSuccessResponse(httpResponse, 201);
  } catch (error) {
    handleDbQueryError(error, httpResponse);
  }
};

// ---------------------- READ ---------------------- //

export const getEntity = async (
  entityName: string,
  httpRequest: Request,
  httpResponse: Response
) => {
  const queryParams = getQueryParams(httpRequest);
  if (queryParams.length === 0) {
    return httpResponse.status(400).end();
  }
  return wrappeResponseHandling(
    entityName,
    queryParams,
    httpResponse,
    async () => {
      return getRowByColumns(queryParams, entityName);
    }
  );
};

export const getEntityWithRelation = async (
  parentEntityName: string,
  childEntityName: string,
  httpRequest: Request,
  httpResponse: Response
) => {
  const queryParams = getQueryParams(httpRequest);
  if (!queryParams) {
    return httpResponse.status(400).end();
  }
  return wrappeResponseHandling(
    parentEntityName,
    queryParams,
    httpResponse,
    async () => {
      return getRelationByColumns(
        queryParams,
        parentEntityName,
        childEntityName
      );
    }
  );
};

// ---------------------- UPDATE ---------------------- //

export async function updateEntity(
  entityName: string,
  httpRequest: Request,
  httpResponse: Response
): Promise<void>;
export async function updateEntity(
  entityName: string,
  httpRequest: Request,
  httpResponse: Response,
  requestBody: JSObject
): Promise<void>;
export async function updateEntity(
  entityName: string,
  httpRequest: Request,
  httpResponse: Response,
  data?: JSObject
): Promise<void> {
  if (!data) {
    data = JSON.parse(httpRequest.body);
  }
  const entityId = httpRequest.params.id;
  const query = buildUpdateQueryFromJSON(
    entityName,
    data as JSObject,
    entityId
  );

  wrappeResponseHandling(
    entityName,
    [{ first: "id", second: entityId }],
    httpResponse,
    async (): Promise<JSObject> => {
      return (await execQuery(query.text, query.paramValues))[0];
    }
  );
}

export const updateEntityWithRelation = async (
  parentEntityName: string,
  childEntityName: string,
  httpRequest: Request,
  httpResponse: Response
) => {
  const entityId = httpRequest.params.id;
  const data = JSON.parse(httpRequest.body);
  const updateParentEntityQuery = buildUpdateQueryFromJSON(
    parentEntityName,
    data[parentEntityName],
    httpRequest.params.id
  );
  const updateChildEntityQuery = buildUpdateQueryFromJSON(
    childEntityName,
    data[childEntityName],
    httpRequest.params.id
  );

  wrappeResponseHandling(
    childEntityName,
    [{ first: "id", second: entityId }],
    httpResponse,
    async (): Promise<JSObject> => {
      return (
        await execQueriesInTransaction([
          updateParentEntityQuery,
          updateChildEntityQuery,
        ])
      )[0];
    }
  );
};

// ---------------------- DELETE ---------------------- //

export const deleteEntity = async (
  entityName: string,
  httpRequest: Request,
  httpResponse: Response
) => {
  const entityId = httpRequest.params.id;
  return wrappeResponseHandling(
    entityName,
    [{ first: "id", second: entityId }],
    httpResponse,
    async (): Promise<JSObject> => {
      return (
        await execQuery("DELETE FROM account WHERE id = $1", [entityId])
      )[0];
    }
  );
};
