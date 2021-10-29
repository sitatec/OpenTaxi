"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const db_1 = require("./db");
const server_1 = __importDefault(require("./server"));
const server = new server_1.default();
db_1.Database.initialize();
server.start();
