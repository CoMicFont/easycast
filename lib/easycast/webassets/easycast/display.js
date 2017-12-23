/**
 * Refreshes the display if the backend current scene is
 * not the same as `sceneIndex`.
 *
 * This function is first called in display.mustache for
 * the current display, and then loops using the code
 * below...
 */
function refreshDisplay(sceneIndex) {
  // Register the function for execution in 200 ms.
  var register = function(){
    setTimeout(function(){
      refreshDisplay(sceneIndex);
    }, 250)
  };

  // When the backend respond...
  var onSuccess = function(res){
    var current = parseInt(res);
    if (current != sceneIndex) {
      // Refresh if the current scene has changed backend
      // side.
      //
      // We don't need to re-register, since the page will
      // reload fully, and reenter the refreshDisplay function
      // itself...
      window.location = window.location;
    } else {
      // No change, simply register the check a bit later...
      register();
    }
  };

  // When the backend fails to respond, simply register the
  // check. This ensures that errors are eventually recovered.
  var onError = register;

  // Make the backend call to known the current scene, and react
  // accordingly.
  jQuery.ajax({
    method: 'GET',
    url: '/scene',
    success: onSuccess,
    error: onError
  });
}
