import { Request, Response } from "express";
import { execQueriesInTransaction, execQuery } from "../db";
import { JSObject, Pair } from "../types";
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
    const query = buildInsertQueryFromJSON(entityName, httpRequest.body);
    const queryResult = await execQuery(query.text, query.paramValues);
    sendSuccessResponse(httpResponse, 201, queryResult.rowCount);
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
  const data = httpRequest.body;
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
  httpResponse: Response,
  parentTablePrimaryKey = "id"
) => {
  const queryParams = getQueryParams(httpRequest);
  if (!queryParams) {
    return httpResponse.status(400).end();
  }
  return wrappeResponseHandling(
    childEntityName,
    queryParams,
    httpResponse,
    async () => {
      return getRelationByColumns(
        queryParams,
        parentEntityName,
        childEntityName,
        parentTablePrimaryKey
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
  }
  let entityId = httpRequest.params.id;
  if(entityName == "account"){
    entityId = `'${entityId}'`;
  }
  const query = buildUpdateQueryFromJSON(
    entityName,
    httpRequest.body,
    entityId
  );

  return wrappeResponseHandling(
    entityName,
    [new Pair("id", entityId)],
    httpResponse,
    async (): Promise<any> => {
      return (await execQuery(query.text, query.paramValues)).rowCount;
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
  const data = httpRequest.body;
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

  return wrappeResponseHandling(
    childEntityName,
    [new Pair("id", entityId)],
    httpResponse,
    async (): Promise<number | JSObject> => {
      return (
        await execQueriesInTransaction([
          updateParentEntityQuery,
          updateChildEntityQuery,
        ])
      ).rowCount;
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
    [new Pair("id", entityId)],
    httpResponse,
    async (): Promise<any> => {
      return (
        await execQuery("DELETE FROM account WHERE id = $1", [entityId])
      ).rowCount;
    }
  );
};
