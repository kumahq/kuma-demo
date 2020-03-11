const items = require("../db/items.json");
const { promisify } = require("util");
const redis = require("redis");

const createClient = () => {
  return redis.createClient({
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    retry_strategy: function(options) {
      if (options.error && options.error.code === "ECONNREFUSED") {
        return new Error("The Redis server refused the connection");
      }
      if (options.total_retry_time > 1000) {
        return new Error("Retry time exhausted");
      }
      if (options.attempt > 1000) {
        return new Error(
          "Creating Redis client attempt failed, retrying again"
        );
      }
      return Math.min(options.attempt * 100, 1000);
    }
  });
};

const search = async itemId => {
  let client = await createClient();
  client.on("error", err => {
    return new Error("Cannot reach /search endpoint, Redis is currently down");
  });
  const getAsync = promisify(client.get).bind(client);
  const res = await getAsync(itemId);

  if (res == null) {
    return new Error("Item does not exist");
  }

  return res;
};

const importData = async () => {
  let client = await createClient();
  items.forEach(item => {
    client.set(item.index, JSON.stringify(item.reviews));
  });
};

module.exports = Object.assign({
  search,
  importData
});
