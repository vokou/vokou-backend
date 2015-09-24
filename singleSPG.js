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
      content = page.content;
      if( content.indexOf('Loading...') > -1 || content.indexOf('Sorry') > -1){
        console.log("No room");
        phantom.exit();
      }
      price = content.substring(content.indexOf('>USD $'));
      price = price.substring(0,price.indexOf('</span>'));

      console.log(price.replace(/[^\d]/g,''));
      // console.log(content);
      phantom.exit();
    }
  });
}
