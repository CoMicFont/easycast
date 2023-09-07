/**
 * Callback used on refresh() on display pages.
 *
 * This callback refreshes the page the hard way, by forcing
 * the location to change.
 */
function refreshDisplay(current, register){

  var onSuccess = function(result) {
    jQuery("main").replaceWith(result);
    register();
  }

  var onError = function(){
    register();
  }

  jQuery.ajax({
    method: 'GET',
    url: window.location,
    headers: {
      "Accept": "application/vnd.easycast.display+html"
    },
    success: onSuccess,
    error: onError
  });
}
