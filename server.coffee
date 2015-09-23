express  = require 'express'
app      = express()
port     = process.env.PORT || 8888;
fs       = require 'fs'
timeout      = require 'connect-timeout'
morgan       = require 'morgan'
bodyParser   = require 'body-parser'

allowCrossDomain = (req, res, next)->
    res.header('Access-Control-Allow-Origin', 'example.com');
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next();




haltOnTimedout = (req, res, next)->
  if (!req.timedout)
    next()
  else
    req.status(500).send('response time out!')

# set up our express application
accessLogStream = fs.createWriteStream(__dirname + '/access.log', {flags: 'a'})
app.use morgan('combined',{stream: accessLogStream}) # log every request to the console
app.use bodyParser.json()
app.use bodyParser.urlencoded({
  extended: true
})

app.use timeout(1200000)
app.use haltOnTimedout
app.use allowCrossDomain

require('./app/routes') app

# launch ======================================================================
app.listen port
console.log 'The magic happens on port '+port
