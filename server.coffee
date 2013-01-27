express = require 'express'
app = express()

app.configure ->
  app.use(express.static(__dirname + '/static'))


app.get '/', (req, res) ->
  res.render 'index.html'
app.listen(process.env.VCAP_APP_PORT || 3000)
