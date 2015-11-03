crypto    = require('crypto')
unidecode = require('unidecode')
request = require('request')
map = require('../mapping.json')

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
  app.get '/source/:sourceURL',  (req, res)->
    # res.setHeader("Access-Control-Allow-Origin","*");
    link = "http://www.hotelscombined.com/ProviderRedirect.ashx?"+req.params.sourceURL;
    redcmd = './phantomjs redirect.js ' + link;
    console.log(redcmd);
    exec redcmd,  (error, stdout, stderr)->
      console.log(stdout);
      res.send(stdout);


  app.get '/getSPG', (req, res)->
    if !req.query.checkin
      return res.status(500).end("wrong!"+ !req.query.checkin+" "+!req.query.checkout+" "+!req.query.propID+" "+!req.query.hotelname)

    temp = {}
    temp.name = req.query.hotelname
    temp.detail = map[temp.name];
    name = temp.name.replace(/-/g,'').replace(/,/g,'').replace(/\./g,'').replace(/&/g,'').replace(/\s+/g,'_').replace('_a_Luxury_Collection_Hotel','')
    name = unidecode(name)
    t = req.query.checkin.split('/')
    ci = t[2]+'-'+t[0]+'-'+t[1]
    t = req.query.checkout.split('/')
    co = t[2]+'-'+t[0]+'-'+t[1]
    temp.hcurl = "http://www.hotelscombined.com/Hotel/SearchResults?destination=hotel:"+name+"&radius=0mi&checkin="+ci+"&checkout="+co+"&Rooms=1&adults_1=2&fileName="+name
    url = "http://www.starwoodhotels.com/sheraton/rates/room.html?departureDate="+co+"&arrivalDate="+ci+"&ctx=search&priceMin=&propertyId="+req.query.propID+"&sortOrder=&accessible=&numberOfRooms=1&numberOfAdults=1&bedType=&priceMax=&numberOfChildren=0&nonSmoking=&currencyCode=USD"
    temp.url = url
    cmd = './phantomjs singleSPG.js "'+ url + '"'
    # console.log url
    exec cmd, (error, stdout, stderr)->
      if stdout.indexOf('No') > -1
        temp.lsp = '';
      else
        temp.lsp = stdout.replace('\n','');
      res.send(JSON.stringify(temp));

  app.post '/getPrice', (req, res)->
    # res.setHeader("Access-Control-Allow-Origin","*");
    if !req.body.hcurl || !req.body.price
      return res.status(500).end("wrong url!")
    url = req.body.hcurl
    # url = "http://www.hotelscombined.com/Hotel/SearchResults?destination=hotel:Le_Royal_Meridien_Shanghai&radius=0mi&checkin=2015-09-23&checkout=2015-09-24&Rooms=1&adults_1=2&fileName=Le_Royal_Meridien_Shanghai"
    if( url.indexOf('hotelscombined') > -1)
      cmd = './phantomjs hc.js "'+ url + '" '+req.body.price
    else
      cmd = ""

    if cmd == ""
      return res.status(500).end("wrong url company!")

    exec cmd, (error, stdout, stderr)->
      res.send(stdout)

  app.get '/search',(req, res)->
    # res.setHeader("Access-Control-Allow-Origin","*");
    if req.query.health
      return res.end();


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
    # if url.indexOf(req.query.checkin) <= -1
    #   return res.status(500).end("ci doesnt match!")
    #
    #
    # if url.indexOf(req.query.checkout) <= -1
    #   return res.status(500).end("co doesnt match!")

    type = ''
    if( url.indexOf('starwoodhotels') > -1)
      cmd = './phantomjs spg.js "'+ url + '"'
      type = 'spg'
    else if(url.indexOf('hyatt') > -1)
      cmd = './phantomjs hyatt.js "'+ url + '"'
      type = 'hyatt'
    else
      cmd = ""

    if cmd == ""
      return res.status(500).end("wrong hotel company!")

    exec cmd, (error, stdout, stderr)->
      if type == 'spg'
        lines = stdout.split '\n'
        i = 0
        result = []
        for line in lines
          try
            temp = JSON.parse line
            temp.detail = map[temp.name];
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
            if t>min && t!=0
              min = t
              msg = "Cash + Points"
            if temp.lsp == 9999
              temp.lsp = ''
            temp.pp = {point_plan: msg, value: min}
            temp.url = "http://www.hotelscombined.com/Hotel/SearchResults?destination=hotel:"+name+"&radius=0mi&checkin="+ci+"&checkout="+co+"&Rooms=1&adults_1=2&fileName="+name
            temp.spgurl = "http://www.starwoodhotels.com/sheraton/rates/room.html?departureDate="+co+"&arrivalDate="+ci+"&ctx=search&priceMin=&propertyId="+temp.detail.id+"&sortOrder=&accessible=&numberOfRooms=1&numberOfAdults=1&bedType=&priceMax=&numberOfChildren=0&nonSmoking=&currencyCode=USD"
            if Number(req.query.propID) == temp.detail.id
              temp.spgurl = "http://www.starwoodhotels.com/sheraton/rates/room.html?departureDate="+co+"&arrivalDate="+ci+"&ctx=search&priceMin=&propertyId="+temp.detail.id+"&sortOrder=&accessible=&numberOfRooms=1&numberOfAdults=1&bedType=&priceMax=&numberOfChildren=0&nonSmoking=&currencyCode=USD"
              return res.json(temp)
            result.push temp
          catch error
            continue;
        if req.query.propID
          res.send('');
        else
          res.json(result)
      else if type == 'hyatt'
        # console.log cmd
        result = JSON.parse(stdout)
        for item in result
          item.url = "http://www.hotelscombined.com/Hotel/SearchResults?destination=hotel:"+name+"&radius=0mi&checkin="+ci+"&checkout="+co+"&Rooms=1&adults_1=2&fileName="+item.name
          console.log item.url
        res.end(stdout);

module.exports = routes
