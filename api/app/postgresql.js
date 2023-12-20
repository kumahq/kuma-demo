const items = require("../db/items.json");
const { Pool } = require("pg");
const pino = require('pino');
const logger = pino({ name: 'kuma-backend' });
const dns = require('node:dns');


const pool = new Pool({
  user: process.env.POSTGRES_USER || "kumademo",
  host: process.env.POSTGRES_HOST || "localhost",
  database: process.env.POSTGRES_DB || "kumademo",
  password: process.env.POSTGRES_PASSWORD || "kumademo",
  port: process.env.POSTGRES_PORT_NUM || 5432, //POSTGRES_PORT environmental variable is taken on K8S
  idleTimeoutMillis: 10000,
  connectionTimeoutMillis: 2000,
});

pool.on("error", (err, clients) => {
  logger.error('error on postgresql pool', err);
  process.exit(-1);
});

const search = async (itemName) => {
  logger.info('searching the DB...');
  logger.info('pool details: ' + JSON.stringify(pool));
  try {
    const result = await pool.query(
      `SELECT data FROM marketItems WHERE name ILIKE '%${itemName}%'`
    );
    logger.info('search result: ' + JSON.stringify(result));
    return result;
  } catch (err) {
    logger.info("configured host in pool: " + pool.options.host);
    logger.error('search error: ', err);
    dns.lookup(pool.options.host, (err, address, family) => {
      logger.error('from pool config, found dns address: ' + address + ', family: ' + family);
      logger.error('dns err: ' + err);
    }
    );
  }
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
      logger.error("Release");
      client.release();
    }
  })().catch((e) => logger.error(e.stack));
};

module.exports = Object.assign({
  search,
  importData,
});
