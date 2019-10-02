const items = require('../test/items.json')

const elasticsearch = require('elasticsearch')
const client = new elasticsearch.Client({
    hosts: [ (process.env.ES_HOST || `http://localhost:9200`) ],
    maxRetries: 30,
    requestTimeout: 30000
})

client.ping({
    requestTimeout: 30000,
}, (error) => {
    if (error) {
        console.error('elasticsearch cluster is down!')
    }
})

const search = (itemName) => {
    client.ping({
        requestTimeout: 10,
    }, (error) => {
        if (error) {
            console.error('elasticsearch cluster is down, unable to search')
            return new Error(error)
        }
    })

    let body = {
        size: 200,
        from: 0,
        query: {
            query_string: {
                default_field: "name",
                query: `*${itemName}*`
            }
        }
    }

    return client.search({
        index: 'market-items',
        body: body
    })
}

const searchId = (itemId) => {
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
    })
}

const createBulk = async () => {
    let bulk = []

    client.indices.create({
        index: 'market-items'
    }, (error, response, status) => {
        if (error) {
            console.log(error)
        } else {
            console.log("created a new index", response)
        }
    })

    await items.forEach(item => {
        item.reviews = undefined

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

const importData = async () => {
    const bulk = await createBulk()

    client.bulk({
        body: bulk
    }, (err, response) => {
        if (err) {
            console.log("Failed Bulk operation", err)
            return {}
        } else {
            console.log("Successfully imported, total items: ", bulk.length)
            return {}
        }
    })
}

module.exports = Object.assign({
    search,
    searchId,
    importData
})