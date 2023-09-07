function refreshSwitcher(current, register) {
  var onSuccess = function(result) {
    jQuery("main").replaceWith(result);
    installButtonList();
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
