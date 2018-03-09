/**
 * Show first image and install a timeout
 * that will hide it and show the next one
 */
function installGallery(id, interval) {
  var images = jQuery("#" + id + " img");
  images.hide();

  function slideshow(current) {
    images.hide();
    jQuery(images[current]).show();
    setTimeout(function(){
      slideshow((current + 1) % images.length);
    }, interval);
  }

  slideshow(0);
}
