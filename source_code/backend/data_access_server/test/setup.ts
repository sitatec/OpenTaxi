import { Database } from "../src/db";
import Server from "../src/server";

declare module global {
  let __SERVER__: Server
}

export default async function () {
  process.env.NODE_ENV = "test";
  global.__SERVER__ = new Server();
  global.__SERVER__.start();
}