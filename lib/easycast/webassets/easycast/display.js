/**
 * Refreshes the display if the backend current node is
 * not the same as `nodeIndex`.
 *
 * This function is first called in display.mustache for
 * the current display, and then loops using the code
 * below...
 */
function refreshDisplay(nodeIndex) {
  // Register the function for execution in 200 ms.
  var register = function(){
    setTimeout(function(){
      refreshDisplay(nodeIndex);
    }, 250)
  };

  // When the backend respond...
  var onSuccess = function(res){
    var current = parseInt(res);
    if (current != nodeIndex) {
      // Refresh if the current node has changed backend
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

  // Make the backend call to known the current node, and react
  // accordingly.
  jQuery.ajax({
    method: 'GET',
    url: '/node',
    success: onSuccess,
    error: onError
  });
}
