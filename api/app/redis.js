const items = require("../db/items.json");
const { createClient } = require("redis");
const pino = require('pino');
const logger = pino({ name: 'kuma-backend-redis', level: process.env.PINO_LOG_LEVEL || 'info' });

// Redis connection from the environment.
//
//   REDIS_HOST / REDIS_PORT
//   REDIS_TLS=true                       enable TLS (managed providers such as STACKIT
//                                         require it)
//   REDIS_TLS_REJECT_UNAUTHORIZED=true   verify the server cert (default: false)
//   REDIS_USERNAME / REDIS_PASSWORD      ACL credentials (managed Redis is authenticated)
//
// Unset credentials / TLS keep the client working against a plain local Redis.
const useTls = ["true", "1", "yes"].includes(String(process.env.REDIS_TLS || "").toLowerCase());

const socket = {
  host: process.env.REDIS_HOST || "localhost",
  port: Number(process.env.REDIS_PORT) || 6379,
};
if (useTls) {
  socket.tls = true;
  // Managed Redis (e.g. STACKIT/a9s) sits behind an SNI-routing TLS proxy that closes
  // connections without a Server Name Indication, so set it explicitly to the host.
  socket.servername = socket.host;
  socket.rejectUnauthorized =
    String(process.env.REDIS_TLS_REJECT_UNAUTHORIZED || "").toLowerCase() === "true";
}

const client = createClient({
  socket,
  username: process.env.REDIS_USERNAME || undefined,
  password: process.env.REDIS_PASSWORD || undefined,
});

client.on("error", (err) => logger.error({ err }, "redis client error"));

// Connect once, lazily; reset on failure so a later call can retry.
let connectPromise;
const ensureConnected = async () => {
  if (client.isOpen) return;
  if (!connectPromise) {
    connectPromise = client.connect().catch((err) => {
      connectPromise = null;
      throw err;
    });
  }
  await connectPromise;
};

const search = async (itemId) => {
  await ensureConnected();
  const res = await client.get(String(itemId));
  if (res == null) {
    return new Error("Item does not exist");
  }
  return res;
};

const importData = async () => {
  await ensureConnected();
  await Promise.all(
    items.map((item) => client.set(String(item.index), JSON.stringify(item.reviews)))
  );
  logger.info("imported reviews for %d items into Redis", items.length);
};

module.exports = Object.assign({
  search,
  importData,
});
