const items = require('../test/items.json')
const elasticsearch = require('elasticsearch')

let client;

const createClient = () => {
    client = client || new elasticsearch.Client({
        hosts: [(process.env.ES_HOST || `http://localhost:9200`)],
        maxRetries: 30,
        requestTimeout: 30000
    })
}

const search = async (itemName) => {
    await createClient()
    let body = {
        size: 200,
        from: 0,
        query: {
            query_string: {
                default_field: 'name',
                query: `*${itemName}*`
            }
        }
    }

    return client.search({
        index: 'market-items',
        body: body
    }, {
        ignore: [404],
        maxRetries: 3
    }, (err, { body }) => {
        if (err) console.log(err)
    })
}

const searchId = async (itemId) => {
    await createClient()
    let body = {
        query: {
            match: {
                index: itemId
            }
        }
    }

    return client.search({
        index: 'market-items',
        body: body
    }, {
        ignore: [404],
        maxRetries: 3
    }, (err, { body }) => {
        if (err) console.log(err)
    })
}

const createBulk = async () => {
    await createClient()
    let bulk = []

    client.indices.create({
        index: 'market-items'
    }, (err, response, status) => {
        if (err) {
            return new Error('Creating ES Indices failed');
        }
    })

    await items.forEach(item => {
        item.reviews = undefined

        bulk.push({
            index: {
                _index: 'market-items',
                _type: 'clothing_list'
            }
        })
        bulk.push(item)
    })

    return bulk
}

const importData = async () => {
    const bulk = await createBulk()

    client.bulk({
        body: bulk
    }, (err, response) => {
        if (err) {
            return new Error('Failed Bulk operation');
        }
    })
}

module.exports = Object.assign({
    search,
    searchId,
    importData
})