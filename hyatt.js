var system = require('system');
var args = system.args;
var DEBUG = true;
var unidecode = require('unidecode');

if(args.length != (1+1) ){
  console.log('error: lack of parameters');
  phantom.exit();
}
else{
  var url = args[1];
  var resultObject = {};
  var ratio = 1;

  var page = require('webpage').create(),
    url = url


  page.open(url, function (status) {
    if (status !== 'success') {
      console.log('error: Unable to access network '+ status);
      phantom.exit();
    } else {
      var jsonSource = page.plainText;
      resultObject = JSON.parse(jsonSource);
    }

    page.open("https://native.usablenet.com/ws/hyatt-nat/v3/getCurrency?env=prod&platform=iphone&currency="+resultObject.currency, function (status) {
      if (status !== 'success') {
        console.log('error: Unable to access network '+ status);
        phantom.exit();
      }
      else{
        jsonSource = page.plainText;
        var tempObject = JSON.parse(jsonSource);
        ratio = tempObject.ratio
      }
      result = resultObject.results
      for (var i = 0; i < result.length; i++) {
          var tempObject = result[i];
          // console.log(JSON.stringify(tempObject));
          if(tempObject.isSoldOut == true){
            tempObject.pp = {point_plan: "No Best Point Plan", value: 0};
            tempObject.lsp = 9999;
          }else{
            tempObject.lsp = tempObject.price/ratio;
            tempObject.passportPoint = tempObject.passportPoint.replace(/,/g,'');
            tempObject.passportPoint = Number(tempObject.passportPoint);
            tempObject.pp = {point_plan: "Points", value: tempObject.lsp/tempObject.passportPoint};
            tempObject.points = tempObject.passportPoint;
          }
          tempObject.detail = {id:tempObject.code, address: tempObject.address}
          if(tempObject["currency"]){
            delete tempObject["currency"];
          }
          if(tempObject["image"]){
            delete tempObject["image"];
          }
          if(tempObject["passportPoint"]){
            delete tempObject["passportPoint"];
          }
          if(tempObject["isSoldOut"]){
            delete tempObject["isSoldOut"];
          }
          if(tempObject["price"]){
            delete tempObject["price"];
          }
          if(tempObject["colorCode"]){
            delete tempObject["colorCode"];
          }
          if(tempObject["code"]){
            delete tempObject["code"];
          }
          if(tempObject["brand"]){
            delete tempObject["brand"];
          }
          if(tempObject["description"]){
            delete tempObject["description"];
          }
          if(tempObject["phone"]){
            delete tempObject["phone"];
          }
          if(tempObject["distance"]){
            delete tempObject["distance"];
          }
          if(tempObject["address"]){
            delete tempObject["address"];
          }
          if(tempObject["coords"]){
            delete tempObject["coords"];
          }
          if(tempObject["detailsWSUrl"]){
            delete tempObject["detailsWSUrl"];
          }
          if(tempObject["bookingRatesMwUrl"]){
            delete tempObject["bookingRatesMwUrl"];
          }

      }
      console.log(JSON.stringify(result));
      phantom.exit();
    });

    // phantom.exit();
  });
  // phantom.exit();

  page.onConsoleMessage = function (msg) {
    console.log(msg);
  };
}
