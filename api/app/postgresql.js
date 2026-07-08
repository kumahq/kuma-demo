const items = require("../db/items.json");
const { Pool } = require("pg");
const fs = require("fs");
const pino = require('pino');
const logger = pino({ name: 'kuma-backend-pg', level: process.env.PINO_LOG_LEVEL || 'info' });
const dns = require('dns');
const dnsPromises = dns.promises;

// Build the node-postgres SSL config from the environment.
//
//   POSTGRES_SSL=true                    enable TLS (managed providers such as STACKIT
//                                         reject unencrypted connections)
//   POSTGRES_SSL_CA / POSTGRES_SSL_CA_FILE  verify the server against this CA (PEM /
//                                         file path); when set, verification is on
//   POSTGRES_SSL_REJECT_UNAUTHORIZED=false  encrypt without verifying the server cert
//
// Unset (the default) keeps SSL off, so local/in-cluster Postgres keeps working.
function buildSslConfig() {
  const mode = String(process.env.POSTGRES_SSL || "").toLowerCase();
  if (!["true", "require", "1", "yes"].includes(mode)) {
    return false;
  }
  const ssl = {};
  if (process.env.POSTGRES_SSL_CA) {
    ssl.ca = process.env.POSTGRES_SSL_CA;
  } else if (process.env.POSTGRES_SSL_CA_FILE) {
    ssl.ca = fs.readFileSync(process.env.POSTGRES_SSL_CA_FILE, "utf8");
  }
  if (process.env.POSTGRES_SSL_REJECT_UNAUTHORIZED !== undefined) {
    ssl.rejectUnauthorized =
      String(process.env.POSTGRES_SSL_REJECT_UNAUTHORIZED).toLowerCase() === "true";
  } else {
    // Only verify when we were actually given a CA to verify against.
    ssl.rejectUnauthorized = Boolean(ssl.ca);
  }
  return ssl;
}

const pool = new Pool({
  user: process.env.POSTGRES_USER || "kumademo",
  host: process.env.POSTGRES_HOST || "localhost",
  database: process.env.POSTGRES_DB || "kumademo",
  password: process.env.POSTGRES_PASSWORD || "kumademo",
  port: process.env.POSTGRES_PORT_NUM || 5432, //POSTGRES_PORT environmental variable is taken on K8S
  ssl: buildSslConfig(),
  idleTimeoutMillis: process.env.POSTGRES_IDLE_TIMEOUT || 10000,
  connectionTimeoutMillis: process.env.POSTGRES_CONNECTION_TIMEOUT || 2000,
});

const dnsOptions = {
  all: true,
};

pool.on("error", (err) => {
  logger.error('error on postgresql pool', err);
  process.exit(-1);
});

const search = async (itemName) => {
  const term = itemName || "";
  await dnsPromises.lookup(pool.options.host, dnsOptions).then((result) => {
    logger.info('DNS lookup for host ' + pool.options.host + ': %j', result);
  });
  return await pool.query(
    "SELECT data FROM marketItems WHERE name ILIKE $1",
    [`%${term}%`]
  );
};

const importData = async () => {
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
    for (const item of items) {
      await client.query(
        "INSERT INTO marketItems VALUES($1, $2, $3)",
        [item.index, item.name, JSON.stringify(item)]
      );
    }
    await client.query("COMMIT");
    logger.info("imported %d items into PostgreSQL", items.length);
  } catch (e) {
    logger.error({ err: e }, "importData failed, rolling back");
    await client.query("ROLLBACK");
    throw e;
  } finally {
    client.release();
  }
};

module.exports = Object.assign({
  search,
  importData,
});
