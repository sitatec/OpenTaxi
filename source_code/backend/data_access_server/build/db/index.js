"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.convertToDatabaseErrorIfNeeded = exports.wrappeInTransaction = exports.execQueriesInTransaction = exports.beginTransaction = exports.execQuery = void 0;
const pg_1 = require("pg");
const error_1 = require("./error");
// TODO Document.
const dbClient = new pg_1.Pool({
    user: "postgres",
    host: "localhost",
    database: "postgres",
    password: "sitatech",
    port: 5432,
});
pg_1.types.setTypeParser(pg_1.types.builtins.NUMERIC, (val) => {
    if (val.length < 16) {
        if (val.includes(".")) {
            return parseFloat(val);
        }
        else {
            return parseInt(val);
        }
    }
    else {
        return BigInt(val);
    }
});
async function execQuery(query, queryParams) {
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
        const queryResult = (await dbClient.query(text, params));
        return {
            rows: queryResult.rows,
            rowCount: queryResult.rowCount
        };
    }
    catch (error) {
        throw (0, exports.convertToDatabaseErrorIfNeeded)(error);
    }
}
exports.execQuery = execQuery;
const beginTransaction = async () => {
    const transactionClient = await dbClient.connect();
    await transactionClient.query("BEGIN");
    return transactionClient;
};
exports.beginTransaction = beginTransaction;
/**
 * Execute the given `queries[]` in the same order they are placed in the array.
 * A transaction is automatically opened, the queries are executed and then the
 * transaction is automatically closed.
 */
const execQueriesInTransaction = async (queries) => {
    return (0, exports.wrappeInTransaction)(async (dbTransactionClient) => {
        const firstQuery = queries.shift();
        const result = await dbTransactionClient.query(firstQuery.text, firstQuery.paramValues);
        for (const query of queries) {
            await dbTransactionClient.query(query.text, query.paramValues);
        }
        return {
            rows: result.rows,
            rowCount: result.rowCount
        };
    });
};
exports.execQueriesInTransaction = execQueriesInTransaction;
const wrappeInTransaction = async (queriesExecutor) => {
    const dbTransactionClient = await (0, exports.beginTransaction)();
    try {
        const result = await queriesExecutor(dbTransactionClient);
        await dbTransactionClient.query("COMMIT");
        return result;
    }
    catch (error) {
        await dbTransactionClient.query("ROLLBACK");
        throw (0, exports.convertToDatabaseErrorIfNeeded)(error);
    }
    finally {
        dbTransactionClient.release();
    }
};
exports.wrappeInTransaction = wrappeInTransaction;
const convertToDatabaseErrorIfNeeded = (error) => {
    if (error instanceof pg_1.DatabaseError) {
        return (0, error_1.convertToDatabaseError)(error);
    }
    else {
        return error;
    }
};
exports.convertToDatabaseErrorIfNeeded = convertToDatabaseErrorIfNeeded;
