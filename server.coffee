express = require 'express'
nodemailer = require 'nodemailer'
formidable = require 'formidable'

app = express()

app.configure ->
  app.use express.static("#{__dirname}/static")
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.set 'view options', layout: true
  app.use express.methodOverride()
  app.use app.router


app.get '/', (req, res) ->
  res.render 'main'

app.get '/registration', (req, res) ->
  res.render 'registration'

smtpTransport = nodemailer.createTransport "SMTP",
  service: "Gmail", auth: {user: "vystup.z.rady@gmail.com", pass: "Vystupzrady"}
  
app.post '/registration', (req, res) ->
  form = new formidable.IncomingForm()
  form.parse req, (err, fields, files) ->
    if err
      res.send 500, "Nepodarilo se poslat mail, prosim zkus to jeste jednou..."
      return
    else
      sendMail fields, res

sendMail = (fields, res) ->
  registrationMail = {
    from: "Our website",
    to: "vystup.z.rady@gmail.com",
    subject: "Prihlaska od #{fields.name}",
    text: """
jmeno: #{fields.name}
e-mail: #{fields.email}
telefon: #{fields.phone}
odkud prijede: #{fields.going_from}
vegetarian: #{if fields.vegetarian then 'ano' else 'ne'}
vegan:#{if fields.vegan then 'ano' else 'ne'}
jine stravovaci omezeni: #{fields.other_food_restrictions}
zdravotni omezeni: #{fields.health_restictions}
motivace: #{fields.motivation}
tesi se na: #{fields.look_forwards}
jine (vzkazy nebo otazky): #{fields.other}
    """,
  }
  smtpTransport.sendMail registrationMail, (error, response) ->
    if error
      console.error JSON.stringify error
      res.send 500, "Nepodarilo se poslat mail, prosim zkus to jeste jednou..."
    else
      res.send 'Registrace probehla uspesne! Vrat se <a href="/">zpet</a>.'

  confirmationMail = {
    from: "Kurz Vystup z rady!",
    to: "#{fields.email}",
    subject: "Potvrzeni registrace",
    text: """
Ahoj,

Tvá registrace byla úspěšně přijata. Děkujeme Ti za přihlášení!
Zanedlouho se Ti ozveme s dalšími informacemi ohledně kurzu.

Zatím se měj krásně!
lektorský tým Vystup z řady!
"""
  }
  smtpTransport.sendMail confirmationMail, (error, response) ->
    if error
      console.error JSON.stringify error
    else
      console.log 'cofirmationMail sent'

app.listen(process.env.VCAP_APP_PORT || 3000)
