const items = require("../db/items.json");
const { Pool } = require("pg");

const pool = new Pool({
  user: process.env.POSTGRES_USER || "kumademo",
  host: process.env.POSTGRES_HOST || "localhost",
  database: process.env.POSTGRES_DB || "kumademo",
  password: process.env.POSTGRES_PASSWORD || "kumademo",
  port: process.env.POSTGRES_PORT_NUM || 5432, //POSTGRES_PORT environmental variable is taken on K8S
});

pool.on("error", (err, clients) => {
  console.error("Unexpected error on idle client", err);
  process.exit(-1);
});

const search = async (itemName) => {
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
      console.log("Error");
      await client.query("ROLLBACK");
      throw e;
    } finally {
      console.log("Release");
      client.release();
    }
  })().catch((e) => console.error(e.stack));
};

module.exports = Object.assign({
  search,
  importData,
});
