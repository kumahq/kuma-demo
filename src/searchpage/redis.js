const items = require('./test/items.json')

const redis = require("redis")
const client = redis.createClient()
const { promisify } = require('util')
const getAsync = promisify(client.get).bind(client)

client.on('connect', () => {
    console.log('Redis client connected')
})

const search = async (itemId) => {
    const res = await getAsync(itemId);

    if (res == null) {
        console.log('Item does not exist, please check the item index provided.')
        return err
    }

    return res
}

const importData = () => {
    items.forEach(item => {
        client.set(item.index, JSON.stringify(item.reviews))
    })
}

module.exports = Object.assign({
    search,
    importData
})