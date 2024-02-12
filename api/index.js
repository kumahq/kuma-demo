const redis = require("./app/redis");
const postgresql = require("./app/postgresql");
const promBundle = require("express-prom-bundle");
const pino = require('pino');
const logger = pino({ name: 'kuma-backend', level: process.env.PINO_LOG_LEVEL || 'info' });

const express = require("express");
const app = express();

const metricsMiddleware = promBundle({includeMethod: true});
const bodyParser = require("body-parser");
let specialOffers = process.env.SPECIAL_OFFER || true;
let totalOffers = process.env.TOTAL_OFFER || 1;

app.use(metricsMiddleware);
app.use(bodyParser.json());
app.set("port", process.env.PORT || 3001);
app.set("etag", false);
app.use((req, res, next) => {
  res.set("Cache-Control", "no-store, no-cache, must-revalidate, private");
  next();
});
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "PUT, GET, POST, DELETE, OPTIONS");
  res.header("Access-Control-Allow-Headers", "*");
  next();
});

app.get("/", (req, res) => {
  res.set(req.headers);
  logger.info('GET /');
  res.send(
    "Hello World! Marketplace with sales and reviews made with <3 by the OCTO team at Kong Inc."
  );
});

app.post("/upload", async (req, res) => {
  await redis.importData();
  await postgresql.importData();
  res.end("Mock data updated in Redis and PostgreSQL!");
});

app.get("/items", async (req, res) => {
  await logger.info('get on /items');
  await postgresql
    .search(req.query.q)
    .then(async (results) => {
      if (results === undefined) {
        logger.error('result is undefined');
      }
      if (results.rows === undefined) {
        logger.error('result.rows is undefined');
      }
      if (results.rows.length === 0) {
        logger.warn('no results found');
      } else {
        logger.info('row count: ' + results.rowCount);
      }
      if (specialOffers == true) {
        res.send(addOffer(results.rows));
      } else {
        res.send(results.rows);
      }
    })
    .catch((err) => {
      logger.error('catch err: ' + err);;
      res.send(err);
    });
});

const addOffer = (arr) => {
  let items = arr;

  if (items.length == 0) {
    return items;
  }

  for (i = 0; i < totalOffers; i++) {
    items[i].data.specialOffer = true;
  }

  return items;
};

app.get("/items/:itemIndexId/reviews", (req, res) => {
  logger.info('get on /items/.../reviews');
  redis
    .search(`${req.params.itemIndexId}`, req.headers)
    .then((results) => {
      res.send(results);
    })
    .catch((err) => {
      logger.error('catch err: ' + err);;
      res.send(err);
    });
});

app.listen(app.get("port"), "0.0.0.0");
