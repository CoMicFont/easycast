/**
 * Callback used on refresh() on the remote page.
 *
 * This callback refreshes the remote the soft way, by changing
 * the `active` css classes of the old and new menu items. This
 * prevents the remote to jump on top of the page, which would
 * be unfriendly as hell...
 */
function refreshRemote(current, register){
  jQuery("main.remote > ul li.active").removeClass("active");
  jQuery("main.remote > ul li.node-" + current.walkIndex).addClass("active");

  var offset = jQuery("main.remote > ul li.active").offset();
  var height = window.innerHeight;
  jQuery('html, body').animate({
      scrollTop: offset.top - height/3,
      scrollLeft: offset.left
  });

  if (current.paused) {
    jQuery("#scheduler_icon").addClass("fa-play");
    jQuery("#scheduler_icon").removeClass("fa-pause");
  } else {
    jQuery("#scheduler_icon").removeClass("fa-play");
    jQuery("#scheduler_icon").addClass("fa-pause");
  }

  register();
}

jQuery(function(){
  jQuery("#cogs-toggle").click(function(event){
    jQuery("main.remote > ul.prev-next").hide();
    jQuery("main.remote > ul.cogs").show();
  });

  jQuery("#cogs-back").click(function(event){
    jQuery("main.remote > ul.prev-next").show();
    jQuery("main.remote > ul.cogs").hide();
  });

  // Find the remote links and replace the current GET behavior
  // by an ajax POST equivalent.
  //
  // POST /scene/x sets the x-th scene as the current one. All
  // other displays will react accordingly.
  jQuery("main.remote > ul > li a").click(function(event){
    var href = jQuery(this).attr('href');
    if (href) {
      var check = jQuery(this).data("confirm");
      if (!check || confirm('Etes-vous sûr.e?')) {
        event.preventDefault();
        event.stopPropagation();
        $.ajax({
          url: href,
          method: 'POST',
          data: {}
        });
      }
    }
    return false;
  })
});
