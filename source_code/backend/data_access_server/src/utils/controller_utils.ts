import { Response } from "express";
import { handleDbQueryError } from "./database_utils";
import { JSObject, Pair } from "../types";
import { sendSuccessResponse } from "./http_utils";

export const wrappeResponseHandling = async (
  entityName: string,
  queryParams: Pair<string, string>[],
  httpResponse: Response,
  fn: () => Promise<number | JSObject>
) => {
  try {
    const result = await fn();
    if (result) {
      sendSuccessResponse(httpResponse, 200, result);
    } else {
      httpResponse.status(404).send({
        message: `${entityName} with ${queryParams.join(" & ")} not found.`,
        status: "failure",
      });
    }
  } catch (error) {
    handleDbQueryError(error, httpResponse);
  }
};

export const handleUnknownError = (error: any, res: Response) =>
  res
    .status(500)
    .send({
      massage: "Server Error. " + error.message + " | " + error.toString(),
      status: "failure",
    });
