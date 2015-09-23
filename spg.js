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
      // console.log(page.content);
      var results = page.evaluate(function() {
        var list = document.querySelectorAll('.propertyInner');
        var i, t;
        var name = "";
        var lsp = "";
        var points = "";
        var cp = "";
        var hotels = [];
        var temp;
        var pre_string="";
        var lines;
        for (i = 0; i < list.length; i++) {
          lines = list[i].innerText.split('\n');
          for( t = 0; t< lines.length; t++){
            if(lines[t] != 'NEW' && lines[t].indexOf('Please')<=-1 && lines[t].indexOf('Opening')<=-1 && lines[t].indexOf('Find')<=-1 && lines[t].indexOf('This') && lines[t] != 'From' &&
              lines[t] != 'per night')
            {
              temp = lines[t];
              pre_string+=temp+'\n';
            }
          }
        }
        lines = pre_string.split('\n');
        i = 0;
        min = 9999;
        for( t = 0; t< lines.length; t++){
          if( lines[t].indexOf('Starpoints')>-1 ){
            if( lines[t+1] && lines[t+1].indexOf('+')>-1 ){
              cp = {points: Number(lines[t].split(" ")[0].replace(',','')), usd: Number(lines[++t].slice(6))};
            }else{
              points = Number( lines[t].split(" ")[0].replace(',','') );
            }
          }else if( lines[t].indexOf('USD')>-1 ){
            var usd = Number(lines[t].slice(5).replace(',',''));
            if(usd<min){
                min = usd;
            }
          }else if( lines[t] == '' ){
            if(name == ""){
              continue;
            }
            lsp = min;
            hotels.push({name: name, lsp: lsp, points: points, cp: cp});
            name = "";
            lsp = "";
            points = "";
            cp = "";
            min = 9999;
          }else{
            name = lines[t];
          }
        }
        return hotels;
      });


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
