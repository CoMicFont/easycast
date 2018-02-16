function openMenu(event) {
  event.preventDefault();
  event.stopPropagation();
  document.getElementById("menu").style.left = "0px";
}

function closeMenu(event) {
  event.preventDefault();
  event.stopPropagation();
  document.getElementById("menu").style.left = "-350px";
}

function installMenu() {
  if (!document.getElementById("menu")) return;
  $(".open-menu-btn").click(openMenu);
  $(".close-menu-btn").click(closeMenu);
  $("body").click(closeMenu);
}
$(installMenu);