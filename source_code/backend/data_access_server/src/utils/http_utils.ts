import { IncomingHttpHeaders } from "http";

export const extractTokenFromHeader = (header: IncomingHttpHeaders): string | undefined => {
  return header.authorization?.replace(RegExp("^Bearer\s+$"), "");
}