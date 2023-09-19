function splashWait(targetUrl) {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      window.location = targetUrl;
    } else if (this.readyState == 4) {
      setTimeout(function(){
        splashWait(targetUrl);
      }, 1000);
    }
  };
  console.log("Trying to reach master at " + targetUrl);
  xhttp.open("GET", targetUrl, true);
  xhttp.send();
}

function splashConnect() {
  const queryString = window.location.search;
  const urlParams = new URLSearchParams(queryString);
  const targetUrl = decodeURIComponent(urlParams.get('target') || "http://easycast/");

  function refresh() {
    window.location = window.location;
  }
  setTimeout(refresh, 15000);

  setTimeout(function() {
    splashWait(targetUrl);
  }, 500);
}

function splashReconnect() {
  jQuery('aside.splash').show();

  splashWait(window.location);
}
