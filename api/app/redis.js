const items = require('../test/items.json')
const { promisify } = require('util')
const redis = require("redis")

let client;

const getClient = () => {
    client = client || redis.createClient({
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
    });
    return client
};

const search = async (itemId) => {
    client.on('connect', () => {
        console.log('Redis client connected, beginning search...')
    })

    client.on('error', (err) => {
        
        console.log ('Cannot reach /search endpoint, Redis is currently down')
        return new Error('Redis is down')
    })    
    const getAsync = promisify(client.get).bind(client)
    const res = await getAsync(itemId);

    if (res == null) {
        console.log('Item does not exist, please check the item index provided.')
        return new Error('Item does not exist')
    }

    return res
}

const importData =  async () => {
    await getClient()
    let count = 0
    items.forEach(item => {
        console.log(`Adding item ${count += 1} to Redis`)
        client.set(item.index, JSON.stringify(item.reviews))
    })
}

module.exports = Object.assign({
    search,
    importData
})