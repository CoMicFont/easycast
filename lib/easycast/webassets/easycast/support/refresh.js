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
  var onSuccess = function(event, force) {
    if (event.type === 'state') {
      var newState = event.detail;
      if (force || (newState.walkIndex != currentState.walkIndex) || (newState.paused != currentState.paused)) {
        actualRefresher(newState, function() {
          currentState = newState;
        });
      }
    } else if (event.type === 'video') {
      var elm = document.getElementsByTagName("video")[0];
      if (elm) {
        switch (event.detail.command) {
          case 'play':
            elm.play();
            break;
          case 'pause':
            elm.pause();
            break;
          case 'backward':
            elm.currentTime = elm.currentTime - 3;
            break;
          case 'forward':
            elm.currentTime = elm.currentTime + 3;
            break;
        }
      }
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

  var pollit = function(force) {
    jQuery.ajax({
      method: 'GET',
      url: "/state",
      success: function(data){
        onSuccess({
          type: 'state',
          detail: data
        }, force);
        setTimeout(pollit, 2500);
      },
      error: onError
    });
  }
  pollit(true);
}
