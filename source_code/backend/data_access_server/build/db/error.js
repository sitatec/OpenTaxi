"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.convertToDatabaseError = exports.DatabaseError = void 0;
class DatabaseError extends Error {
    constructor(name, message, code) {
        super(message);
        this.name = name;
        this.code = code;
    }
}
exports.DatabaseError = DatabaseError;
const convertToDatabaseError = (error) => {
    switch (error.code) {
        // TODO handle more case.
        case "42703":
            return new DatabaseError(error.name, error.message, // `Error: the field ${error.column} does not exist for the ${error.table} entity.`,
            error.code);
        case "23502":
            // TODO check if all the requiered field are given in a middleware.
            return new DatabaseError(error.name, `Error: the field ${error.column} cannot be null.`, error.code);
        default:
            return new DatabaseError("unknown", error.message, error.code);
    }
};
exports.convertToDatabaseError = convertToDatabaseError;
