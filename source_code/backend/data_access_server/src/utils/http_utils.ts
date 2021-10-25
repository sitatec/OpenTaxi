import { Response } from "express";
import { IncomingHttpHeaders } from "http";

export const extractTokenFromHeader = (header: IncomingHttpHeaders): string | undefined => {
  return header.authorization?.replace(RegExp("^Bearer\s+$"), "");
}

export const sendSuccessResponse = (res: Response, statusCode?: number) => {
  res.status(statusCode || 200).send({ status: "success" })
}