import { Server } from "http";
// import { stopDb } from "../src/db";

declare module global {
  let __SERVER__: Server
}

export default async function () {
  // await stopDb();
  global.__SERVER__.close();
}