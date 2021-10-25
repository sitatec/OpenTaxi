import { DatabaseError as PGDatabaseError, Pool, PoolClient } from "pg";
import { JSObject, Query } from "../types";
import { convertToDatabaseError, DatabaseError } from "./error";

// TODO Document.

const dbClient = new Pool({
  user: "postgres",
  host: "localhost",
  database: "postgres",
  password: "sitatech",
  port: 5432,
});
// TODO set the posgresql server's timezone the south africa's timezone.

export async function execQuery(
  query: string,
  queryParams?: Array<string | number>
): Promise<JSObject[]>;

export async function execQuery(query: Query): Promise<JSObject[]>;

export async function execQuery(
  query: any,
  queryParams?: any
): Promise<JSObject[]> {
  let text: string;
  let params: (string | number)[];
  if (typeof query === "string") {
    text = query;
    params = queryParams;
  } else {
    text = query.text;
    params = query.paramValues;
  }
  try {
    return (await dbClient.query(text, params)).rows;
  } catch (error) {
    throw convertToDatabaseErrorIfNeeded(error);
  }
}

export const beginTransaction = async () => {
  const transactionClient = await dbClient.connect();
  await transactionClient.query("BEGIN");
  return transactionClient;
};

/**
 * Execute the given `queries[]` in the same order they are placed in the array.
 * A transaction is automatically opened, the queries are executed and then the
 * transaction is automatically closed.
 */
export const execQueriesInTransaction = async (queries: Query[]) => {
  return wrappeInTransaction(async (dbTransactionClient) => {
    for (const query of queries) {
      await dbTransactionClient.query(query.text, query.paramValues);
    }
  });
};

export const wrappeInTransaction = async (
  queriesExecutor: (clien: PoolClient) => Promise<void>
) => {
  const dbTransactionClient = await beginTransaction();
  try {
    await queriesExecutor(dbTransactionClient);
    await dbTransactionClient.query("COMMIT");
  } catch (error) {
    await dbTransactionClient.query("ROLLBACK");
    throw convertToDatabaseErrorIfNeeded(error);
  } finally {
    dbTransactionClient.release();
  }
};

export const convertToDatabaseErrorIfNeeded = (error: any) => {
  if (error instanceof PGDatabaseError) {
    return convertToDatabaseError(error);
  } else {
    return error;
  }
};
