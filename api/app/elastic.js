const items = require('../db/items.json')
const elasticsearch = require('elasticsearch')

const client = elasticsearch.Client({
    hosts: [(process.env.ES_HOST || `http://localhost:9200`)],
    maxRetries: 5,
    requestTimeout: 60000
})


const search = async (itemName) => {
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
        maxRetries: 1
    }, (err, {
        body
    }) => {
        if (err) console.log(err)
    })
}

const searchId = async (itemId) => {
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
    }, (err, {
        body
    }) => {
        if (err) console.log(err)
    })
}

const createBulk = async () => {
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
    return bulk
}

module.exports = Object.assign({
    search,
    searchId,
    importData
})