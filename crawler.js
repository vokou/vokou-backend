var hotels = require('./hotels.json');
var page = require('webpage').create();
var keysbyindex = Object.keys(hotels);
var fs = require('fs');

var path = 'output.txt';

var fetch = function(hotels, index, r){
  if(keysbyindex.length == index){
    fs.write(path, JSON.stringify(hotels), 'w');
    phantom.exit();
  }
  console.debug(index+"/"+keysbyindex.length);
  var id = hotels[keysbyindex[index]].id;
  // console.log(id);
  url = "https://api.starwoodhotels.com/property/"+ id+"?apiKey=u0dl4flhksq01sd9hct67bu2ko8ty7ae&locale=en_US";
  page.open(url, function (status) {
    if (status !== 'success') {
      console.log('error1: Unable to access network '+ status);
      phantom.exit();
    } else {
      var jsonSource = page.plainText;
      // var resultObject = JSON.parse(jsonSource);
      // console.log("NAME: "+resultObject['propertyContentResponse']['properties']['property']['summary']['propertyName']);
      var img = "http://www.starwoodhotels.com"+jsonSource.substring(jsonSource.indexOf('/pub'),jsonSource.indexOf('jpg'))+"jpg";
      var address = jsonSource.substring(jsonSource.indexOf('"addressLine":'),jsonSource.indexOf('] }, "phone":')).substring(14)+']';
      hotels[keysbyindex[index]].img = img;
      hotels[keysbyindex[index]].address = address.replace(/\s\s+|\"|\[|\]/g,'');
      // console.log(address);
      // console.log(JSON.stringify(hotels[keysbyindex[index]]));
      index++;
      fetch(hotels, index, result);
    }
  });
}

var result = false;
fetch(hotels, 0, result);
