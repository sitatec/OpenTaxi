import { Server } from "http";

declare module global {
  let __SERVER__: Server
}

export default async function () {
  global.__SERVER__.close();
}