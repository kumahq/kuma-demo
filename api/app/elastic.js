const items = require("../db/items.json");
const elasticsearch = require("elasticsearch");

const client = elasticsearch.Client({
  hosts: [process.env.ES_HOST || `http://localhost:9200`],
  maxRetries: 5,
  requestTimeout: 60000
});

const search = async (itemName, header) => {
  let body = {
    size: 200,
    from: 0,
    query: {
      query_string: {
        default_field: "name",
        query: `*${itemName}*`
      }
    }
  };

  return client.search(
    {
      index: "market-items",
      body: body,
      headers: headersToPass(header)
    },
    {
      ignore: [404],
      maxRetries: 3
    },
    (err, { body }) => {
      if (err) console.log(err);
    }
  );
};

const searchId = async (itemId, header) => {
  let body = {
    query: {
      match: {
        index: itemId
      }
    }
  };

  return client.search(
    {
      index: "market-items",
      body: body,
      headers: headersToPass(header)
    },
    {
      ignore: [404],
      maxRetries: 3
    },
    (err, { body }) => {
      if (err) console.log(err);
    }
  );
};

const createBulk = async header => {
  let bulk = [];

  client.indices.create(
    {
      index: "market-items",
      headers: headersToPass(header)
    },
    (err, response, status) => {
      if (err) {
        return new Error("Creating ES Indices failed");
      }
    }
  );

  await items.forEach(item => {
    item.reviews = undefined;

    bulk.push({
      index: {
        _index: "market-items",
        _type: "clothing_list"
      }
    });
    bulk.push(item);
  });

  return bulk;
};

const importData = async header => {
  const bulk = await createBulk();

  client.bulk(
    {
      body: bulk,
      headers: headersToPass(header)
    },
    (err, response) => {
      if (err) {
        return new Error("Failed Bulk operation");
      }
    }
  );
  return bulk;
};

// Only pass predefined headers.
const headerNames = [
  "x-request-id",
  "x-b3-traceid",
  "x-b3-parentspanid",
  "x-b3-spanid",
  "x-b3-sampled",
  "x-b3-flags"
];

const headersToPass = async headers => {
  let headerArr = headerNames
    .filter(headerName => headers[headerName] !== undefined)
    .map(headerName => [headerName, headers[headerName]]);

  return headerArr.length == 0 ? {} : headerArr.reduce(withObjectAssign, {});
};

// Alternative to Object.fromEntries
const withObjectAssign = (object, [key, value]) => {
  return Object.assign(object, { [key]: value });
};

module.exports = Object.assign({
  search,
  searchId,
  importData
});
