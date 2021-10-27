import { Request, Response } from "express";
import {
  createEntityWithRelation,
  getEntityWithRelation,
  updateEntity,
  updateEntityWithRelation,
} from "./_generic_controllers";
import { deleteAccount } from "./account_controller";

export const createDriver = async (
  httpRequest: Request,
  httpResponse: Response
) => createEntityWithRelation("account", "driver", httpRequest, httpResponse);

export const getDriver = async (httpRequest: Request, httpResponse: Response) =>
  getEntityWithRelation("account", "driver", httpRequest, httpResponse);

export const updateDriver = async (
  httpRequest: Request,
  httpResponse: Response
) => {
  if (httpRequest.body.account) {
    return updateEntityWithRelation(
      "account",
      "driver",
      httpRequest,
      httpResponse
    );
  } else {
    return updateEntity("driver", httpRequest, httpResponse);
  }
};

export const deleteDriver = deleteAccount; // Deleting the account will delete the
// driver data too, because a CASCADE constraint is specified on the account_id
// column.
