const items = require("../db/items.json");
const elasticsearch = require("elasticsearch");

const createClient = async () => {
  return elasticsearch.Client({
    hosts: [process.env.ES_HOST || `http://localhost:9200`],
    maxRetries: 30,
    requestTimeout: 30000
  });
};

const search = async (itemName, header) => {
  let client = await createClient();

  let body = {
    size: 200,
    from: 0,
    query: {
      query_string: {
        default_field: "name",
        query: `*${itemName}*`
      }
    },
  };

  return client.search(
    {
      index: "market-items",
      body: body,
      headers: headersToPass(header)
    },
    {
      ignore: [404],
      maxRetries: 1
    },
    (err, { body }) => {
      if (err) console.log(err);
    }
  );
};

const searchId = async (itemId, header) => {
  let client = await createClient();
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
  let client = await createClient();
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
  let client = await createClient();
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
const headerNames = ['x-request-id', 'x-b3-traceid', 'x-b3-parentspanid', 'x-b3-spanid', 'x-b3-sampled', 'x-b3-flags'];
function headersToPass(headers) {
  return Object.fromEntries(
      headerNames.filter(headerName => headers[headerName] !== undefined)
          .map(headerName => [headerName, headers[headerName]])
  );
}

module.exports = Object.assign({
  search,
  searchId,
  importData
});
