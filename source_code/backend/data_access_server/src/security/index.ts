import { execQuery } from "../db";
import { JSObject } from "../types";

// export { validateToken } from "./token_validator";

export const isAdminUser = async (userId: string): Promise<boolean> => {
  const result = await execQuery(
    "SELECT role FROM user WHERE id = $1",
    [userId]
  );
  return result.rows[0].role == "ADMIN";
};

export const preventUnauthorizedAccountUpdate = async (requesData: JSObject, userId: string) => {
  delete requesData.id; // The user id must not be changeable.
  delete requesData.role; // A user role can't be changed once created;
  if (requesData.account_status && !(await isAdminUser(userId))) {
  // Here we could just check if the user is not an admin and delete the property
  // but the `isAdminUser(...)` function make a db query (wich is relatively a long operation)
  // so we check first if the the `account_status` is part of the field to be updated.
    delete requesData.account_status; // Only an admin can change the status of an account.
  }
}