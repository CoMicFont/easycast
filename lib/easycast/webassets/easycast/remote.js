jQuery(function(){
  // Find the remote links and replace the current GET behavior
  // by an ajax POST equivalent.
  //
  // POST /scene/x sets the x-th scene as the current one. All
  // other displays will react accordingly.
  jQuery("ul.remote > li a").click(function(event){
    event.preventDefault();
    event.stopPropagation();
    $.ajax({
      url: $(this).attr('href'),
      method: 'POST',
      data: {}
    });
    return false;
  })
});
