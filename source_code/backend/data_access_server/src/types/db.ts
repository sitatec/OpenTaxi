export type Query = {
  text: string;
  paramValues: Array<number | string>;
};

export type QueryResult = {
  rows: any[],
  /**
   * The number of rows affected by the query.
   * 
   * **NOTE** This is not the number of rows returned by the query.
   */
  rowCount: number
};