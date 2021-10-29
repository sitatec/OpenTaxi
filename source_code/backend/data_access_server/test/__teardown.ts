import Server from "../src/server";

declare module global {
  let __SERVER__: Server
}

export default async function () {
  // await stopDb();
  global.__SERVER__.stop();
}