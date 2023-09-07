/**
 * Callback used on refresh() on the remote page.
 *
 * This callback refreshes the remote the soft way, by changing
 * the `active` css classes of the old and new menu items. This
 * prevents the remote to jump on top of the page, which would
 * be unfriendly as hell...
 */
function refreshRemote(current, register) {
  jQuery("main.remote > ul li.active").removeClass("active");
  jQuery("main.remote > ul li.node-" + current.walkIndex).addClass("active");
  jQuery("main.remote > ul li.node-" + current.walkIndex).parent().parent().addClass("collapsed");

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
