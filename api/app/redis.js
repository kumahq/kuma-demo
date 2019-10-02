const items = require('../test/items.json')

const redis = require("redis")
const client = redis.createClient({
    host: process.env.REDIS_HOST,
    port: 6379,
    retry_strategy: function (options) {
        if (options.error && options.error.code === 'ECONNREFUSED') {
            console.log('The Redis server refused the connection')
            return new Error('The Redis server refused the connection');
        }
        if (options.total_retry_time > 1000 * 60 * 60) {
            console.log('Retry time exhausted')
            return new Error('Retry time exhausted');
        }
        if (options.attempt > 5000) {
            console.log('Attempt failed')
            return new Error('Creating Redis client attempt failed, retrying again');
        }
        return Math.min(options.attempt * 100, 3000);
    }
})

const { promisify } = require('util')
const getAsync = promisify(client.get).bind(client)

client.on('connect', () => {
    console.log('Redis client connected')
})

const search = async (itemId) => {
    client.on('connect', () => {
        console.log('Redis client connected, beginning search...')
    })

    client.on('error', (err) => {
        
        console.log ('Cannot reach /search endpoint, Redis is currently down')
        return new Error('Redis is down')
    })    
    
    const res = await getAsync(itemId);

    if (res == null) {
        console.log('Item does not exist, please check the item index provided.')
        return new Error('Item does not exist')
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