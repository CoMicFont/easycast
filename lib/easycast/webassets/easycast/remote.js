jQuery(function(){
  // Find the remote links and replace the current GET behavior
  // by an ajax POST equivalent.
  //
  // POST /scene/x sets the x-th scene as the current one. All
  // other displays will react accordingly.
  jQuery("ul.remote > li > a").click(function(event){
    event.preventDefault();
    event.stopPropagation();

    function refresh() {
      window.location = location;
    }

    $.ajax({
      url: $(this).attr('href'),
      method: 'POST',
      data: {},
      success: refresh,
      error: refresh
    });
    return false;
  })
});
