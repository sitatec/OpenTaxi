import { Database } from "./db";
import { Request, Response } from "express";
import { ENTITIES_WITH_STRING_ID } from "./constants";
import { JSObject, Pair } from "./types";
import { wrappeResponseHandling } from "./utils/controller_utils";
import {
  buildInsertQueryFromJSON,
  buildUpdateQueryFromJSON,
  getRelationByColumns,
  getRowByColumns,
  handleDbQueryError,
} from "./utils/database_utils";
import { getQueryParams, sendSuccessResponse } from "./utils/http_utils";

// TODO delegate the http response handling to the controllers and handle only
// the entity management (i.e: building queries and executing them using the db instance)
// within this class.
export default class EntityManager {
  constructor(private db = Database.initialize()) {}

  async createEntity(
    entityName: string,
    httpRequest: Request,
    httpResponse: Response
  ) {
    try {
      const query = buildInsertQueryFromJSON(entityName, httpRequest.body);
      const queryResult = await this.db.execQuery(
        query.text,
        query.paramValues
      );
      sendSuccessResponse(httpResponse, 201, queryResult.rowCount);
    } catch (error) {
      handleDbQueryError(error, httpResponse);
    }
  }

  createEntityWithRelation = async (
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
      const queryResult = await this.db.execQueriesInTransaction([
        insertParentEntityQuery,
        insertChildEntityQuery,
      ]);
      sendSuccessResponse(httpResponse, 201, queryResult.rowCount);
    } catch (error) {
      handleDbQueryError(error, httpResponse);
    }
  };

  // ---------------------- READ ---------------------- //

  getEntity = (
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

  getEntityWithRelation = (
    parentEntityName: string,
    childEntityName: string,
    httpRequest: Request,
    httpResponse: Response,
    parentTablePrimaryKey = "id",
    childTableForeignKey?: string,
    returnOnlyColunmOfTable = ""
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
          parentTablePrimaryKey,
          childTableForeignKey,
          returnOnlyColunmOfTable
        );
      }
    );
  };

  // ---------------------- UPDATE ---------------------- //

  updateEntity = (
    entityName: string,
    httpRequest: Request,
    httpResponse: Response
  ): Promise<void> => {
    let [entityPrimaryKeyName, entityPrimaryKeyValue] = Object.entries(
      httpRequest.params
    )[0];
    if (ENTITIES_WITH_STRING_ID.includes(entityName)) {
      entityPrimaryKeyValue = `'${entityPrimaryKeyValue}'`;
    }
    delete httpRequest.body[entityPrimaryKeyName]; // IDs must not be modified.
    const query = buildUpdateQueryFromJSON(
      entityName,
      httpRequest.body,
      entityPrimaryKeyValue,
      entityPrimaryKeyName
    );

    return wrappeResponseHandling(
      entityName,
      [new Pair(entityPrimaryKeyName, entityPrimaryKeyValue)],
      httpResponse,
      async (): Promise<any> => {
        return (await this.db.execQuery(query.text, query.paramValues))
          .rowCount;
      }
    );
  };

  updateEntityWithRelation = (
    parentEntityName: string,
    childEntityName: string,
    httpRequest: Request,
    httpResponse: Response
  ) => {
    let [entityPrimaryKeyName, entityPrimaryKeyValue] = Object.entries(
      httpRequest.params
    )[0];
    const data = httpRequest.body;
    if (ENTITIES_WITH_STRING_ID.includes(parentEntityName)) {
      entityPrimaryKeyValue = `'${entityPrimaryKeyValue}'`;
    }
    delete data[parentEntityName]["id"]; // IDs must not be modified.
    const updateParentEntityQuery = buildUpdateQueryFromJSON(
      parentEntityName,
      data[parentEntityName],
      entityPrimaryKeyValue
    );
    delete data[childEntityName][entityPrimaryKeyName]; // IDs must not be modified.
    const updateChildEntityQuery = buildUpdateQueryFromJSON(
      childEntityName,
      data[childEntityName],
      entityPrimaryKeyValue,
      entityPrimaryKeyName
    );

    return wrappeResponseHandling(
      childEntityName,
      [new Pair("id", entityPrimaryKeyValue)],
      httpResponse,
      async (): Promise<number | JSObject> => {
        return (
          await this.db.execQueriesInTransaction([
            updateParentEntityQuery,
            updateChildEntityQuery,
          ])
        ).rowCount;
      }
    );
  };

  // ---------------------- DELETE ---------------------- //

  deleteEntity = (
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
          await this.db.execQuery(`DELETE FROM ${entityName} WHERE id = $1`, [
            entityId,
          ])
        ).rowCount;
      }
    );
  };

  execCustomQuery = (query: string, queryParams?: (string | number)[]) =>
    this.db.execQuery(query, queryParams);
}
