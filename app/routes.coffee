crypto    = require('crypto')
unidecode = require('unidecode')
request = require('request')
jsdom = require('jsdom')

algorithm = 'aes-256-ctr'
password  = 'We are fucking SPG'
exec = require('child_process').exec
DEBUG = true

IsJsonString = (str)->
    try
      JSON.parse str
    catch error
        return false
    return true;


encrypt = (text)->
  cipher = crypto.createCipher(algorithm,password)
  crypted = cipher.update(text,'utf8','hex')
  crypted += cipher.final('hex')
  return crypted


decrypt = (text)->
  decipher = crypto.createDecipher(algorithm,password)
  try
    dec = decipher.update(text,'hex','utf8')
    dec += decipher.final('utf8')
    return dec
  catch ex
    console.log('failed');
    return 'failed';


routes = (app)->
  # app.get '/nodetube', (req, res)->
  #   request = request.defaults({jar: true})
  #   j = request.jar()
  #   request {
  #       headers: {
  #         "Host":"www.hotelscombined.com"
  #         "Connection": "keep-alive"
  #         "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
  #         "Upgrade-Insecure-Requests": "1"
  #         "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.93 Safari/537.36"
  #         "Accept-Encoding": "gzip, deflate, sdch"
  #         "Accept-Language": "en-US,en;q=0.8"
  #       },
  #       uri: 'http://www.hotelscombined.com/'
  #       },(err, response, body)->
  #         # cookie = get(response.headers, "Set-Cookie")
  #         # if cookie
  #         #   cookie = (cookie + "").split(";").shift()
  #         #   console.log(cookie)
  #
  #         # res.send(cookie);
  #         request {
  #             headers: {
  #               "Host":"www.hotelscombined.com"
  #               "Connection": "keep-alive"
  #               "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
  #               "Upgrade-Insecure-Requests": "1"
  #               "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.93 Safari/537.36"
  #               "Accept-Encoding": "gzip, deflate, sdch"
  #               "Accept-Language": "en-US,en;q=0.8"
  #             },
  #             uri: 'http://www.hotelscombined.com/Hotel/SearchResults?destination=hotel:Le_Royal_Meridien_Shanghai&radius=0mi&checkin=2015-09-23&checkout=2015-09-24&Rooms=1&adults_1=2&fileName=Le_Royal_Meridien_Shanghai'
  #           }, (err, response, body)->
  #             self = this
  #             self.items = new Array()
  #             if err && response.statusCode != 200
  #               console.log('Request error.')
  #             console.log(body)



      # jsdom.env {
      #   url: "http://youtube.com",
      #   scripts: ['http://code.jquery.com/jquery-1.6.min.js'],
      #   done:  (err, window) ->
      #     $ = window.$;
      #     console.log("HN Links");
      #     $("td.title:not(:last) a").each ()->
      #       console.log(" -", $(this).text());
      #
      #
      # }


  app.get '/source/:sourceURL',  (req, res)->
    link = "http://www.hotelscombined.com/ProviderRedirect.ashx?"+req.params.sourceURL;
    redcmd = './phantomjs redirect.js ' + link;
    console.log(redcmd);
    exec redcmd,  (error, stdout, stderr)->
      console.log(stdout);
      res.send(stdout);



  app.post '/getPrice', (req, res)->
    res.setHeader("Access-Control-Allow-Origin","*");
    if !req.body.hcurl || !req.body.price
      return res.status(500).end("wrong url!")
    # url = req.body.turl
    url = "http://www.hotelscombined.com/Hotel/SearchResults?destination=hotel:Le_Royal_Meridien_Shanghai&radius=0mi&checkin=2015-09-23&checkout=2015-09-24&Rooms=1&adults_1=2&fileName=Le_Royal_Meridien_Shanghai"
    if( url.indexOf('hotelscombined') > -1)
      cmd = './phantomjs hc.js "'+ url + '" '+req.body.price
    else
      cmd = ""

    if cmd == ""
      return res.status(500).end("wrong url company!")

    exec cmd, (error, stdout, stderr)->
      res.send(stdout)

  app.get '/search',(req, res)->
    res.setHeader("Access-Control-Allow-Origin","*");
    if !req.query.secret
      return res.status(500).end("wrong secret!")
    if !req.query.checkin
      return res.status(500).end("wrong ci!")

    if !req.query.checkout
      return res.status(500).end("wrong co!")

    url = decrypt(req.query.secret)
    if url.indexOf('http')<=-1
      return res.status(500).end("wrong secret!")

    cmd = ""
    if url.indexOf(req.query.checkin) <= -1
      return res.status(500).end("ci doesnt match!")


    if url.indexOf(req.query.checkout) <= -1
      return res.status(500).end("co doesnt match!")

    if( url.indexOf('starwoodhotels') > -1)
      cmd = './phantomjs spg.js "'+ url + '"'
    else
      cmd = ""

    if cmd == ""
      return res.status(500).end("wrong hotel company!")

    exec cmd, (error, stdout, stderr)->
      lines = stdout.split '\n'
      i = 0
      result = []
      for line in lines
        try
          temp = JSON.parse line
          name = temp.name.replace(/-/g,'').replace(/,/g,'').replace(/\./g,'').replace(/&/g,'').replace(/\s+/g,'_').replace('_a_Luxury_Collection_Hotel','')
          name = unidecode(name)
          t = req.query.checkin.split('/')
          ci = t[2]+'-'+t[0]+'-'+t[1]
          t = req.query.checkout.split('/')
          co = t[2]+'-'+t[0]+'-'+t[1]
          min = 0
          t = 0
          msg = "No Best Point Plan"
          if temp.points != "" && temp.lsp != ""
            min = Number(temp.lsp)/Number(temp.points)
            msg = "Points"
          if temp.cp != ""
            t = (Number(temp.lsp)-Number(temp.cp.usd))/Number(temp.cp.points)
          if t<min && t!=0
            min = t
            msg = "Cash + Points"
          if temp.lsp == 5000
            temp.lsp = ''
          temp.pp = {point_plan: msg, value: min}
          temp.url = "http://www.hotelscombined.com/Hotel/SearchResults?destination=hotel:"+name+"&radius=0mi&checkin="+ci+"&checkout="+co+"&Rooms=1&adults_1=2&fileName="+name
          result.push temp
        catch error
          continue;
      res.json(result)


module.exports = routes
