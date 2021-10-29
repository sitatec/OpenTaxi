"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Database = void 0;
const pg_1 = require("pg");
const error_1 = require("./error");
class Database {
    constructor(client) {
        this.client = client;
    }
    static get instance() {
        return this._instance;
    }
    static set instance(value) {
        this._instance = value;
    }
    static initialize(client = new pg_1.Pool({
        user: "postgres",
        host: "localhost",
        database: "postgres",
        password: "postgres",
        port: 5432,
    })) {
        if (!this.initialized) {
            if (process.env.NODE_ENV === "test") {
                client = new pg_1.Pool({
                    user: "postgres",
                    host: "localhost",
                    database: "postgres",
                    password: "postgres",
                    port: 5432,
                    allowExitOnIdle: true,
                });
            }
            else if (process.env.NODE_ENV === "development") {
                client = new pg_1.Pool({
                    user: "postgres",
                    host: "localhost",
                    database: "postgres",
                    password: "postgres",
                    port: 5432,
                });
            }
            this.instance = new Database(client);
            this.initialized = true;
            return this.instance;
        }
    }
    async execQuery(query, queryParams) {
        let text;
        let params;
        if (typeof query === "string") {
            text = query;
            params = queryParams;
        }
        else {
            text = query.text;
            params = query.paramValues;
        }
        try {
            const queryResult = await this.client.query(text, params);
            return {
                rows: queryResult.rows,
                rowCount: queryResult.rowCount,
            };
        }
        catch (error) {
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
    async execQueriesInTransaction(queries) {
        return this.wrappeInTransaction(async (dbTransactionClient) => {
            const firstQuery = queries.shift();
            const result = await dbTransactionClient.query(firstQuery.text, firstQuery.paramValues);
            for (const query of queries) {
                await dbTransactionClient.query(query.text, query.paramValues);
            }
            return {
                rows: result.rows,
                rowCount: result.rowCount,
            };
        });
    }
    async wrappeInTransaction(queriesExecutor) {
        const dbTransactionClient = await this.beginTransaction();
        try {
            const result = await queriesExecutor(dbTransactionClient);
            await dbTransactionClient.query("COMMIT");
            return result;
        }
        catch (error) {
            await dbTransactionClient.query("ROLLBACK");
            throw this.convertToDatabaseErrorIfNeeded(error);
        }
        finally {
            dbTransactionClient.release();
        }
    }
    convertToDatabaseErrorIfNeeded(error) {
        if (error instanceof pg_1.DatabaseError) {
            return (0, error_1.convertToDatabaseError)(error);
        }
        else {
            return error;
        }
    }
}
exports.Database = Database;
Database.initialized = false;
