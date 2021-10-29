"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.preventUnauthorizedAccountUpdate = exports.isAdminUser = void 0;
const db_1 = require("../db");
// export { validateToken } from "./token_validator";
const isAdminUser = async (userId, db = db_1.Database.instance) => {
    const result = await db.execQuery("SELECT role FROM user WHERE id = $1", [userId]);
    return result.rows[0].role == "ADMIN";
};
exports.isAdminUser = isAdminUser;
const preventUnauthorizedAccountUpdate = async (requesData, userId) => {
    delete requesData.id; // The user id must not be changeable.
    delete requesData.role; // A user role can't be changed once created;
    if (requesData.account_status && !(await (0, exports.isAdminUser)(userId))) {
        // Here we could just check if the user is not an admin and delete the property
        // but the `isAdminUser(...)` function make a db query (wich is relatively a long operation)
        // so we check first if the the `account_status` is part of the field to be updated.
        delete requesData.account_status; // Only an admin can change the status of an account.
    }
};
exports.preventUnauthorizedAccountUpdate = preventUnauthorizedAccountUpdate;
