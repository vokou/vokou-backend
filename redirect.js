var page = require('webpage').create();
var system = require('system');
var args = system.args;
var DEBUG = false;
var fs = require('fs');


function ValidUrl(str) {
  var pattern = new RegExp('^(https?:\\/\\/)?'+ // protocol
  '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ // domain name
  '((\\d{1,3}\\.){3}\\d{1,3}))'+ // OR ip (v4) address
  '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // port and path
  '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string
  '(\\#[-a-z\\d_]*)?$','i'); // fragment locator
  if(!pattern.test(str)) {
    return false;
  } else {
    return true;
  }
}

if(args.length != (1+1) ){
  console.log('error: lack of parameters');
  phantom.exit();
}
else{
  var temp_url = args[1];
  if(ValidUrl(temp_url)){
    page.open(temp_url, function () {
      var url = page.evaluate(function() {
        return url;
      });
      url = url.substring(url.indexOf('www.'));
      url = decodeURIComponent(url).replace('hotelscombined','');
      console.log(url);
      phantom.exit();
    });
  }else{
    phantom.exit();
  }
}
