/**
 * Show first image and install a timeout
 * that will hide it and show the next one
 */
function installGallery(id, interval) {

  function slideshow(current) {
    var images = jQuery("#" + id + " img");
    if (images.length > 0) {
      images.hide();
      jQuery(images[current]).show();
      setTimeout(function(){
        slideshow((current + 1) % images.length);
      }, interval);
    }
  }

  slideshow(0);
}
