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
      console.log(page.plainText);
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
      console.log(ratio);
      phantom.exit();
    });

    // phantom.exit();
  });
  // phantom.exit();

  page.onConsoleMessage = function (msg) {
    console.log(msg);
  };
}
