jQuery(function(){
  // Immediately return if this is not the error page...
  if (jQuery("body.error").length == 0) return;

  // Force a hard refresh every 2.5 seconds, so that if the error
  // is eventually recovered, then all displays get refreshed and
  // the show starts fine.
  //
  // Note that the refresh loop is actually provided by the refresh
  // itself, since this file will get executed every time.
  function refresh() {
    window.location = window.location;
  }
  setTimeout(refresh, 2500);
});
