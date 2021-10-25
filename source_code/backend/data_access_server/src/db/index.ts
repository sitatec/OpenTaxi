import { error } from "console";
import { DatabaseError as PGDatabaseError, Pool } from "pg";
import { JSObject } from "../utils/type_alias";
import { DatabaseError } from "./error";

const dbClient = new Pool({
  user: "postgres",
  host: "localhost",
  database: "postgres",
  password: "sitatech",
  port: 5432,
});
// TODO set the posgresql server's timezone the south africa's timezone.

export const execQuery = async (
  query: string,
  queryParams?: Array<string | number>
): Promise<JSObject[]> => {
  try {
    return (await dbClient.query(query, queryParams)).rows;
  } catch (error) {
    if (error instanceof PGDatabaseError) {
      throw convertToDatabaseError(error);
    } else {
      throw error;
    }
  }
};

export const beginTransaction = async () => {
  const transactionClient = await dbClient.connect();
  await transactionClient.query("BEGIN");
  return transactionClient;
};

const convertToDatabaseError = (error: PGDatabaseError) => {
  switch (error.code) {
    // TODO handle more case.
    case "42703":
      return new DatabaseError(
        error.name,
        `Error: the field ${error.column} does not exist for the ${error.table} entity.`,
        error.code
      );
    default:
      return new DatabaseError("unknown", error.message, error.code);
  }
};
