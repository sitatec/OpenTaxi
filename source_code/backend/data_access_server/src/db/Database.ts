interface Database {
  execQuery(query: String, queryParams: Array<any>): Promise<unknown>
}