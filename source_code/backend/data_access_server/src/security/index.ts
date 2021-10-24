import { execQuery } from "../db";

export { validateToken } from "./token_validator";

export const isAdminUser = async (userId: string): Promise<boolean> => {
  const result = await execQuery(
    "SELECT user.role FROM user WHERE user.id = $1",
    [userId]
  );
  return result[0].role == "ADMIN";
};
