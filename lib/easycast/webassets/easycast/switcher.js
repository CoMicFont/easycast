function refreshSwitcher(current, register){
  window.location = window.location;
  register();
}

jQuery(function(){
  // Find the switcher links and replace the current GET behavior
  // by an ajax POST equivalent.
  jQuery("main.switcher > ul li.dynamic > a").click(function(event){
    var href = jQuery(this).attr('href');
    var redirect = jQuery(this).data('redirect');
    if (href) {
      var check = jQuery(this).data("confirm");
      if (!check || confirm('Etes-vous sûr.e?')) {
        event.preventDefault();
        event.stopPropagation();
        $.ajax({
          url: href,
          method: 'POST',
          data: {},
          success: function() {
            if (redirect) {
              window.location = window.location.toString().replace('/switcher', redirect);
            }
          }
        });
      }
    }
    return false;
  })
});
