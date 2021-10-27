import { DatabaseError as PGDatabaseError, Pool, PoolClient, types } from "pg";
import { Query, QueryResult } from "../types/db";
import { convertToDatabaseError } from "./error";

// TODO Document.

const dbClient = new Pool({
  user: "postgres",
  host: "localhost",
  database: "postgres",
  password: "sitatech",
  port: 5432,
});


types.setTypeParser(types.builtins.NUMERIC, (val) => {
  if(val.length < 16) {
    if(val.includes(".")){
      return parseFloat(val);
    }else{
      return parseInt(val);
    }
  }else {
    return BigInt(val);
  }
});

// TODO set the posgresql server's timezone the south africa's timezone.

export async function execQuery(
  query: string,
  queryParams?: Array<string | number>
): Promise<QueryResult>;

export async function execQuery(query: Query): Promise<QueryResult>;

export async function execQuery(
  query: any,
  queryParams?: any
): Promise<QueryResult> {
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
    const queryResult = (await dbClient.query(text, params));
    return {
      rows: queryResult.rows,
      rowCount: queryResult.rowCount
    }
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
    const firstQuery = queries.shift() as Query;
    const result = await dbTransactionClient.query(
      firstQuery.text,
      firstQuery.paramValues
    );
    for (const query of queries) {
      await dbTransactionClient.query(query.text, query.paramValues);
    }
    return {
      rows: result.rows,
      rowCount: result.rowCount
    };
  });
};

export const wrappeInTransaction = async (
  queriesExecutor: (clien: PoolClient) => Promise<QueryResult>
) => {
  const dbTransactionClient = await beginTransaction();
  try {
    const result = await queriesExecutor(dbTransactionClient);
    await dbTransactionClient.query("COMMIT");
    return result;
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
