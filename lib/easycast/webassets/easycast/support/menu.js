jQuery(function(){

  var menuElm = null;

  /**
   * Opens the menu and makes sure the currently active
   * item is visible.
   */
  function openMenu(event) {
    event.preventDefault();
    event.stopPropagation();
    var offset = menuElm.find("ul li.active").offset();
    var height = window.innerHeight;
    menuElm.css({left: 0});
    menuElm.addClass("open");
    menuElm.animate({
        scrollTop: offset.top - height/2,
        scrollLeft: offset.left
    });
  }

  /**
   * Closes the menu.
   */
  function closeMenu(event) {
    event.preventDefault();
    event.stopPropagation();
    menuElm.css({left: -350});
    menuElm.removeClass("open");
  }

  /**
   * Installs the menu, if present on the page, connecting
   * openMenu and closeMenu handlers on widgets.
   */
  function installMenu() {
    if (!document.getElementById("menu")) return;
    menuElm = jQuery("#menu");
    jQuery(".open-menu-btn").click(openMenu);
    jQuery(".close-menu-btn").click(closeMenu);
    jQuery("body").click(closeMenu);
  }

  installMenu();

});
