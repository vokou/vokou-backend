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
  var page = require('webpage').create(),
    url = url


  page.open(url, function (status) {
    if (status !== 'success') {
      console.log('error: Unable to access network '+ status);
      phantom.exit();
    } else {
      console.log(page.content);
      // var results = page.evaluate(function() {
      //   //9999 is no room
      // });


      var i;
      for(i=0 ; i < results.length ; i++){
        console.log(JSON.stringify(results[i]));
      }
    }
    phantom.exit();
  });

  page.onConsoleMessage = function (msg) {
    console.log(msg);
  };
}
