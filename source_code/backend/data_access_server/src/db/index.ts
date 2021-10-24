import {Pool} from 'pg';

const dbClient = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: 'sitatech',
  port: 5432,
});
// TODO set the posgresql server's timezone the south africa's timezone.

export const execQuery = async (query: string, queryParams?: Array<any>)
: Promise<Array<any>> => {
  return (await dbClient.query(query, queryParams)).rows;
};
