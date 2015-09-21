var system = require('system');
var args = system.args;
var DEBUG = true;
var unidecode = require('unidecode');

if(args.length != (1+2) ){
  console.log('error: lack of parameters');
  phantom.exit();
}
else{
  var url = args[1];
  var price = Number(args[2]);
  var page = require('webpage').create(),
  url = url
  var cookie = "";
  var tempurl = "http://www.hotelscombined.com/";
  page.open(tempurl, function (status) {
    if (status !== 'success') {
      console.log('error1: Unable to access network '+ status);
      phantom.exit();
    } else {
      setTimeout(function() {
        page.open(url, function (status) {
          if (status !== 'success') {
            console.log('error1: Unable to access network '+ status);
            phantom.exit();
          } else {
            setTimeout(function() {
              page.open(url, function (status) {
                if (status !== 'success') {
                  console.log('error1: Unable to access network '+ status);
                  phantom.exit();
                } else {
                  var results = page.evaluate( function(price) {
                    var i;
                    var list = document.querySelectorAll('.hc_tbl_col2');
                    var brandList = document.querySelectorAll('.hc_tbl_col4');
                    for (i = 1; i < list.length; i++) {
                      lines = list[i].innerText;
                      brand = brandList[i-1].innerHTML;
                      if(Number(lines.substring(1)) < price){
                        if(brand.indexOf('CTE') <= -1){
                          // console.log(Number(lines.substring(1)));
                          // console.log(brand.substring(brand.indexOf('key'), brand.indexOf('" t')));
                          return {"price":Number(lines.substring(1)), "turl":brand.substring(brand.indexOf('key'), brand.indexOf('" t'))}
                          break;
                        }
                      }
                    }
                  }, price );

                  console.log(JSON.stringify(results));
                }
                phantom.exit();
              });
            },1000);
          }
        });
      },10);
    }
  });
}

page.onConsoleMessage = function (msg) {
  console.log(msg);
};
