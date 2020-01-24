/**
 * Callback used on refresh() on the doors page.
 */
function refreshDoors(current, register){
  jQuery("ul.doors li.active").removeClass("active");
  jQuery("ul.doors li.node-" + current.doorIndex).addClass("active");
}

jQuery(function(){
  // Find the doors links and replace the current GET behavior
  // by an ajax POST equivalent.
  jQuery("ul.doors > li a").click(function(event){
    var href = jQuery(this).attr('href');
    if (href) {
      event.preventDefault();
      event.stopPropagation();
      $.ajax({
        url: href,
        method: 'POST',
        data: {}
      });
    }
    return false;
  })
});
