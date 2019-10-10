const redis = require('./app/redis')
const elastic = require('./app/elastic')

const express = require('express')
const app = express()
const bodyParser = require('body-parser')

app.use(bodyParser.json())
app.set('port', process.env.PORT || 3001)
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*")
  res.header('Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS')
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
  next()
})

app.get('/', (req, res) => {
  res.send('Hello World! Made with <3 by the OCTO team at Kong Inc.')
})

app.post('/upload', async (req, res) => {
  await redis.importData()
  await elastic.importData()
  res.end('Mock data updated in Redis and ES!')
})

app.get('/items', (req, res) => {
  elastic.search(req.query.q)
    .then(results => {
      res.send(results.hits.hits)
    })
    .catch(err => {
      res.send(err)
    })
})

app.get('/items/:itemIndexId', (req, res) => {
  elastic.searchId(req.params.itemIndexId)
    .then(results => {
      res.send(results.hits.hits)
    })
    .catch(err => {
      res.send(err)
    }) 
})

app.get('/items/:itemIndexId/reviews', (req, res) => {
  redis.search(`${req.params.itemIndexId}`)
    .then(results => {
      res.send(results)
    })
    .catch(err => {
      res.send(err)
    })
})

app.listen(app.get('port'))