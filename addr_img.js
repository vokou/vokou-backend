var page = require('webpage').create(),
  url = "http://www.starwoodhotels.com/preferredguest/directory/hotels/all/list.html?language=en_US"

page.open(url, function (status) {
  if (status !== 'success') {
    console.log('error: Unable to access network '+ status);
    phantom.exit();
  } else {
    var results = page.evaluate( function() {
      var list = document.querySelectorAll('.propertyName');
      var result = {};
      for (i = 0; i < list.length; i++) {
        lines = list[i].innerText;
        id = list[i].getAttribute('href');
        if(id == null){
          continue;
        }
        // console.log("HTML: "+list[i].getAttribute('href'));
        id = Number(id.substring(id.indexOf('ID=')).substring(3));
        // console.log(lines+"  : " + id);
        result[lines] = {id: id};
      }
      return result;
    });
    console.log(JSON.stringify(results));
    phantom.exit();
  }
});
page.onConsoleMessage = function (msg) {
  console.log(msg);
};
