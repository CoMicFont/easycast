/**
 * Refreshes the display if the backend current node is
 * not the same as `walkState`.
 *
 * This function is first called in display.mustache for
 * the current display, and then loops using the code
 * below...
 */
function refresh(state, actualRefresher) {
  var currentState = state;

  // When the backend respond...
  var onSuccess = function(newState) {
    if ((newState.walkIndex != currentState.walkIndex) || (newState.paused != currentState.paused)) {
      actualRefresher(newState, function(){
        currentState = newState;
      });
    }
  };

  var onError = function() {
    console.log("Master lost...")
    splashReconnect();
  };

  function connect() {
    console.log("Connecting to notifications...")
    var backendListener = new EventSource('/notifications');
    backendListener.onmessage = function(e) {
      onSuccess(JSON.parse(e.data));
    };
    backendListener.onerror = function(err) {
      console.log("... error on notifications", err);
    };
    backendListener.onopen = function() {
      console.log("... notifications ok!");
    };
  }
  connect();

  var pollit = function(){
    jQuery.ajax({
      method: 'GET',
      url: "/state",
      success: function(data){
        onSuccess(data);
        setTimeout(pollit, 2500);
      },
      error: onError
    });
  }
  setTimeout(pollit, 2500);
}
