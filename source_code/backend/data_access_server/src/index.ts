import { Database } from "./db";
import Server  from "./server";

const server = new Server();
Database.initialize();

server.start();