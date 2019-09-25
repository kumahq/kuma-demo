const redis = require("redis")
const redisClient = redis.createClient()

redisClient.on('connect', function () {
    console.log('Redis client connected')
})
redisClient.set('my test key', 'my test value', redis.print)
redisClient.get('my test key', function (error, result) {
    if (error) {
        console.log(error)
        throw error
    }
    console.log('GET result ->' + result)
})