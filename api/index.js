const redis = require("./app/redis");
const elastic = require("./app/elastic");

const express = require("express");
const app = express();
const bodyParser = require("body-parser");
let specialOffers = process.env.ES_SPECIAL_OFFER || true;
let totalOffers = process.env.ES_TOTAL_OFFER || 1;

app.use(bodyParser.json());
app.set("port", process.env.PORT || 3001);
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "PUT, GET, POST, DELETE, OPTIONS");
  res.header("Access-Control-Allow-Headers", "*");
  next();
});

app.get("/", (req, res) => {
  res.set(req.headers);
  res.send(
    "(v1) Hello World! Marketplace with sales and reviews made with <3 by the OCTO team at Kong Inc."
  );
});

app.post("/upload", async (req, res) => {
  await redis.importData();
  await elastic.importData();
  res.end("Mock data updated in Redis and ES!");
});

app.get("/items", (req, res) => {
  elastic
    .search(req.query.q, req.headers)
    .then(async results => {
      res.set(req.headers);
      if (specialOffers == true) {
        res.send(addOffer(results.hits.hits));
      } else {
        res.send(results.hits.hits);
      }
    })
    .catch(err => {
      res.send(err);
    });
});

let addOffer = arr => {
  let items = arr;
  for (i = 0; i < totalOffers; i++) {
    items[i]._source.specialOffer = true;
  }
  return items;
};

app.get("/items/:itemIndexId", (req, res) => {
  elastic
    .searchId(req.params.itemIndexId, req.headers)
    .then(results => {
      res.set(req.headers);
      res.send(results.hits.hits);
    })
    .catch(err => {
      res.send(err);
    });
});

app.get("/items/:itemIndexId/reviews", (req, res) => {
  redis
    .search(`${req.params.itemIndexId}`, req.headers)
    .then(results => {
      res.set(req.headers);
      res.send(results);
    })
    .catch(err => {
      res.send(err);
    });
});

app.listen(app.get("port"));
