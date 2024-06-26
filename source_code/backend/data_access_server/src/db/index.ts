import {
  DatabaseError as PGDatabaseError,
  Pool,
  PoolClient,
  PoolConfig,
  types,
} from "pg";
import { Query, QueryResult } from "../types/db";
import { convertToDatabaseError } from "./error";

// TODO Document.
// TODO set the posgresql server's timezone the south africa's timezone.


// By default pg-node convert dates to timestamps.
types.setTypeParser(types.builtins.DATE, (date) => date);

interface NewPooConfig extends PoolConfig {
  allowExitOnIdle: boolean;
}

const DB_NAME = process.env.DB_NAME || "postgres";
const DB_USER = process.env.DB_USER || "postgres";
const DB_PASSWORD = process.env.DB_PASSWORD || "postgres";
const DB_PORT = process.env.DB_PORT || "5432";
const DB_HOST =process.env.DB_HOST || "localhost";

export class Database {
  private static initialized = false;

  private static _instance: Database;
  static get instance(): Database {
    return this._instance;
  }

  private static set instance(value) {
    this._instance = value;
  }

  private constructor(private client: Pool) {}

  static initialize(
    client = new Pool({
      user: DB_USER,
      host: DB_HOST,
      database: DB_NAME,
      password: DB_PASSWORD,
      port: parseInt(DB_PORT),
    })
  ) {
    if (!this.initialized) {
      console.log('Initializing DB');
      if (process.env.NODE_ENV === "test") {
        client = new Pool({
          user: "postgres",
          host: "localhost",
          database: "postgres",
          password: "postgres",
          port: 5432,
          allowExitOnIdle: true,
        } as NewPooConfig);
      } else if (process.env.NODE_ENV === "development") {
        client = new Pool({
          user: "postgres",
          host: "localhost",
          database: "postgres",
          password: "postgres",
          port: 5432,
        });
      }
      this.instance = new Database(client);
      this.initialized = true;
    }
    console.log('DB Initialized');
    return this.instance;
  }

  async execQuery(
    query: string,
    queryParams?: Array<string | number>
  ): Promise<QueryResult>;

  async execQuery(query: Query): Promise<QueryResult>;

  async execQuery(query: any, queryParams?: any): Promise<QueryResult> {
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
      const queryResult = await this.client.query(text, params);
      return {
        rows: queryResult.rows,
        rowCount: queryResult.rowCount,
      };
    } catch (error) {
      throw this.convertToDatabaseErrorIfNeeded(error);
    }
  }

  async beginTransaction() {
    const transactionClient = await this.client.connect();
    await transactionClient.query("BEGIN");
    return transactionClient;
  }

  /**
   * Execute the given `queries[]` in the same order they are placed in the array.
   * A transaction is automatically opened, the queries are executed and then the
   * transaction is automatically closed.
   */
  async execQueriesInTransaction(queries: Query[]) {
    return this.wrappeInTransaction(async (dbTransactionClient) => {
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
        rowCount: result.rowCount,
      };
    });
  }

  async wrappeInTransaction(
    queriesExecutor: (clien: PoolClient) => Promise<QueryResult>
  ) {
    const dbTransactionClient = await this.beginTransaction();
    try {
      const result = await queriesExecutor(dbTransactionClient);
      await dbTransactionClient.query("COMMIT");
      return result;
    } catch (error) {
      await dbTransactionClient.query("ROLLBACK");
      throw this.convertToDatabaseErrorIfNeeded(error);
    } finally {
      dbTransactionClient.release();
    }
  }

  convertToDatabaseErrorIfNeeded(error: any) {
    if (error instanceof PGDatabaseError) {
      return convertToDatabaseError(error);
    } else {
      return error;
    }
  }
}
