const redis = require('./app/redis')
redis.importData()
const elastic = require('./app/elastic')
elastic.importData()

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

app.get('/items', (req, res) => {
  elastic.search(req.query.q)
    .then(results => {
      console.log(`found ${results.hits.total.value} items in ${results.took}ms`);
      res.send(results.hits.hits)
    })
    .catch(err => {
      console.log(err)
      res.send([err])
    })
})

app.get('/items/:itemIndexId', (req, res) => {
  elastic.searchId(req.params.itemIndexId)
    .then(results => {
      res.send(results.hits.hits)
    })
    .catch(err => {
      console.log(err)
      res.send([err])
    }) 
})

app.get('/items/:itemIndexId/reviews', (req, res) => {
  redis.search(`${req.params.itemIndexId}`)
    .then(results => {
      res.send(results)
    })
    .catch(err => {
      console.log('Error fetching review from Redis')
      res.send([err])
    })
})

app.listen(app.get('port'), () => {
  console.log('Express server listening on port ' + app.get('port'))
})