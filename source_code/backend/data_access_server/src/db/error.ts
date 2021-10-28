import { DatabaseError as PGDatabaseError } from "pg";

export class DatabaseError extends Error {
  constructor(
    public readonly name: string,
    message: string,
    public readonly code: string | number | undefined
  ) {
    super(message);
  }
}

export const convertToDatabaseError = (error: PGDatabaseError) => {
  switch (error.code) {
    // TODO handle more case.
    case "42703":
      return new DatabaseError(
        error.name,
        error.message,// `Error: the field ${error.column} does not exist for the ${error.table} entity.`,
        error.code
      );
    case "23502":
      // TODO check if all the requiered field are given in a middleware.
      return new DatabaseError(
        error.name,
        `Error: the field ${error.column} cannot be null.`,
        error.code
      );
    default:
      return new DatabaseError("unknown", error.message, error.code);
  }
};
