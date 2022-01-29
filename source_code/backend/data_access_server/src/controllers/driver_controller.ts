import { Request, Response } from "express";
import { Database } from "../db";
import { JSObject } from "../types";
import { buildInsertQueryFromJSON, handleDbQueryError } from "../utils/database_utils";
import { sendSuccessResponse } from "../utils/http_utils";
import Controller from "./controller";

export default class DriverController extends Controller {
  createDriver = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntityWithRelation(
      "account",
      "driver",
      httpRequest,
      httpResponse
    );

  getDriver = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntityWithRelation(
      "account",
      "driver",
      httpRequest,
      httpResponse
    );

  getDriverData = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("driver", httpRequest, httpResponse);

  updateDriver = (httpRequest: Request, httpResponse: Response) => {
    if (httpRequest.body.account) {
      return this.entityManager.updateEntityWithRelation(
        "account",
        "driver",
        httpRequest,
        httpResponse
      );
    } else {
      return this.entityManager.updateEntity(
        "driver",
        httpRequest,
        httpResponse
      );
    }
  };

  deleteDriver = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("account", httpRequest, httpResponse); // Deleting the account will delete the
  // driver data too, because a CASCADE constraint is specified on the account_id
  // column.

  registerDriver = async (httpRequest: Request, httpResponse: Response) => {
    // TODO refactor
    try {
      const data = httpRequest.body;
      const insertDriverAccountQuery = buildInsertQueryFromJSON(
        "account",
        data.account
      );
      const insertDriverHomeAddressQuery = buildInsertQueryFromJSON(
        "address",
        data.address,
        "id"
      );
      const insertDriverBankAccountQuery = buildInsertQueryFromJSON(
        "bank_account",
        data.bank_account
      );

      await Database.instance.wrappeInTransaction(
        async (dbClient) => {
          await dbClient.query(
            insertDriverAccountQuery.text,
            insertDriverAccountQuery.paramValues
          );
          const insertAddressQueryResponse = await dbClient.query(
            insertDriverHomeAddressQuery.text,
            insertDriverHomeAddressQuery.paramValues
          );
          data.driver.home_address_id = insertAddressQueryResponse.rows[0].id;
          const insertDriverQuery = buildInsertQueryFromJSON(
            "driver",
            data.driver
          );
          await dbClient.query(
            insertDriverQuery.text,
            insertDriverQuery.paramValues
          );
          data.emergency_contacts.forEach(
            async (emergencyContact: JSObject) => {
              const insertEmergencyContactQuery = buildInsertQueryFromJSON(
                "emergency_contact",
                emergencyContact
              );
              await dbClient.query(
                insertEmergencyContactQuery.text,
                insertEmergencyContactQuery.paramValues
              );
            }
          );
          return dbClient.query(
            insertDriverBankAccountQuery.text,
            insertDriverBankAccountQuery.paramValues
          );
        }
      );
      sendSuccessResponse(httpResponse, 201, data.account.id);
    } catch (e) {
      console.error(`\n\n${e}\n\n`);
      handleDbQueryError(e, httpResponse);
    }
  };
}
