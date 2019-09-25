const redis = require('./redis')
const elastic = require('./elastic')
elastic.importElasticData()

const express = require('express')
const app = express()
const bodyParser = require('body-parser')

app.use(bodyParser.json())
app.set('port', process.env.PORT || 3001)
app.use(function (req, res, next) {
  res.header("Access-Control-Allow-Origin", "*")
  res.header('Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS')
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
  next()
})

app.get('/search', function (req, res) {
  let body = {
    query: {
      match: {
        name: req.query.item
      }
    }
  }
  elastic.search(body)
    .then(results => {
      console.log(results)
      res.send(results)
    })
    .catch(err => {
      console.log(err)
      res.send([])
    })
})

app.listen(app.get('port'), function () {
  console.log('Express server listening on port ' + app.get('port'))
})