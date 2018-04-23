/**
 * Show first image and install a timeout
 * that will hide it and show the next one
 */
function installGallery(id, images, interval) {

  function slideshow(current) {
    var image = jQuery("#" + id + " img");
    if (image.length > 0) {
      image[0].src = images[current];
      setTimeout(function(){
        slideshow((current + 1) % images.length);
      }, interval);
    }
  }

  slideshow(0);
}
