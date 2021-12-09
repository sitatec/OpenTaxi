import { Request, Response } from "express";
import { IncomingHttpHeaders } from "http";
import { JSObject, Pair } from "../types";

export const extractTokenFromHeader = (
  header: IncomingHttpHeaders
): string | undefined => {
  return header.authorization?.replace("Bearer ", "");
};

export function sendSuccessResponse(httpResponse: Response): void;
export function sendSuccessResponse(httpResponse: Response, data: JSObject): void;
export function sendSuccessResponse(httpResponse: Response, statusCode: number): void;
export function sendSuccessResponse(
  httpResponse: Response,
  statusCode: number,
  data: any
): void;
export function sendSuccessResponse(
  httpResponse: Response,
  statusCode?: any,
  data?: any
) {
  if (data) {
    httpResponse.status(statusCode || 200).send({ data: data, status: "success" });
  } else {
    httpResponse.status(statusCode || 200).send({ status: "success" });
  }
}

export const getQueryParams = (httpRequest: Request): Pair<string, string>[] => {
  const queryParams: Pair<string, string>[] = [];
  for (const [param, paramValue] of Object.entries(httpRequest.query)) {
    queryParams.push(new Pair(param, paramValue as string));
  }
  return queryParams;
};
