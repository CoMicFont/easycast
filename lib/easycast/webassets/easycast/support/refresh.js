/**
 * Refreshes the display if the backend current node is
 * not the same as `walkState`.
 *
 * This function is first called in display.mustache for
 * the current display, and then loops using the code
 * below...
 */
function refresh(state, actualRefresher) {
  // Register the function for execution in 200 ms.
  var register = function(currentState){
    setTimeout(function(){
      refresh(currentState, actualRefresher);
    }, 250)
  };

  // When the backend respond...
  var onSuccess = function(current){
    if ((current.walkIndex != state.walkIndex) || (current.paused != state.paused)) {
      // Refresh if the current node has changed backend
      // side.
      //
      // We don't need to re-register, since the page will
      // reload fully, and reenter the refreshDisplay function
      // itself...
      actualRefresher(current, function(){
        register(current);
      });
    } else {
      // No change, simply register the check a bit later...
      register(current);
    }
  };

  // When the backend fails to respond, simply register the
  // check. This ensures that errors are eventually recovered.
  var onError = register;

  // Make the backend call to known the current node, and react
  // accordingly.
  jQuery.ajax({
    method: 'GET',
    url: '/state',
    success: onSuccess,
    error: onError
  });
}
