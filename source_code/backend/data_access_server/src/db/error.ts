export class DatabaseError extends Error {
  constructor(
    message: string,
    public readonly name: string,
    public readonly code: string | number | undefined
  ) {
    super(message);
  }
}
