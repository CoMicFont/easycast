function openMenu(event) {
  event.preventDefault();
  event.stopPropagation();
  document.getElementById("menu").style.left = "0px";
}

function closeMenu(event) {
  event.preventDefault();
  event.stopPropagation();
  document.getElementById("menu").style.left = "-250px";
}

function installMenu() {
  $(".open-menu-btn").click(openMenu);
  $(".close-menu-btn").click(closeMenu);
  $("body").click(closeMenu);
}
$(installMenu);