import { Server } from "http";
import { startServer } from "../src";

declare module global {
  let __SERVER__: Server
}

export default async function () {
  global.__SERVER__ = startServer();
}