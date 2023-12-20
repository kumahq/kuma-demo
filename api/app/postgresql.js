const items = require("../db/items.json");
const { Pool } = require("pg");
const pino = require('pino');
const logger = pino({ name: 'kuma-backend-pg' });
const dns = require('dns');
const dnsPromises = dns.promises;

const pool = new Pool({
  user: process.env.POSTGRES_USER || "kumademo",
  host: process.env.POSTGRES_HOST || "localhost",
  database: process.env.POSTGRES_DB || "kumademo",
  password: process.env.POSTGRES_PASSWORD || "kumademo",
  port: process.env.POSTGRES_PORT_NUM || 5432, //POSTGRES_PORT environmental variable is taken on K8S
  idleTimeoutMillis: process.env.POSTGRES_IDLE_TIMEOUT || 10000,
  connectionTimeoutMillis: process.env.POSTGRES_CONNECTION_TIMEOUT || 2000,
});

const dnsOptions = {
  all: true,
};

pool.on("error", (err, clients) => {
  logger.error('error on postgresql pool', err);
  process.exit(-1);
});

const search = async (itemName) => {
  logger.info('pool details: ' + JSON.stringify(pool));
  await dnsPromises.lookup(pool.options.host, dnsOptions).then((result) => {
    logger.info('DNS lookup for host ' + pool.options.host + ': %j', result);
  }); 
  return await pool.query(
      `SELECT data FROM marketItems WHERE name ILIKE '%${itemName}%'`
    );
};

const importData = () => {
  (async () => {
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      await client.query("DROP TABLE IF EXISTS marketItems");
      await client.query(
        `CREATE TABLE marketItems(
          index INTEGER PRIMARY KEY,
          name TEXT,
          data JSONB
        )`
      );
      items.forEach((item) => {
        client.query(
          `INSERT INTO marketItems VALUES(${item.index},'${
            item.name
          }','${JSON.stringify(item)}')`
        );
      });
      await client.query("COMMIT");
    } catch (e) {
      logger.error('search error: ', err);
      await client.query("ROLLBACK");
      throw e;
    } finally {
      logger.info("Release");
      client.release();
    }
  })().catch((e) => logger.error(e.stack));
};

module.exports = Object.assign({
  search,
  importData,
});
