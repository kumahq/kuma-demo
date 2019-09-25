const items = require('./test/items.json')

const elasticsearch = require('elasticsearch')
const client = new elasticsearch.Client({
    hosts: ['http://localhost:9200']
})

client.ping({
    requestTimeout: 30000,
}, function (error) {
    if (error) {
        console.error('elasticsearch cluster is down!')
    }
})

const search = (body) => {
    client.search({
            index: 'market-items',
            body: body,
            type: 'clothing_list'
        })
        .then(results => {
            return results.hits.hits
        })
        .catch(err => {
            console.log('elastic.js search() has failed: ' + err)
            return []
        })
}

const createBulk = async () => {
    let bulk = []

    client.indices.create({
        index: 'market-items'
    }, function (error, response, status) {
        if (error) {
            console.log(error)
        } else {
            console.log("created a new index", response)
        }
    })

    await items.forEach(item => {
        bulk.push({
            index: {
                _index: "market-items",
                _type: "clothing_list"
            }
        })
        bulk.push(item)
    })

    return bulk
}

const importElasticData = async () => {
    const bulk = await createBulk()

    client.bulk({
        body: bulk
    }, function (err, response) {
        if (err) {
            console.log("Failed Bulk operation", err);
        } else {
            console.log("Successfully imported, total items: ", bulk.length);
        }
    })
}

module.exports = Object.assign({
    search,
    createBulk,
    importElasticData
})