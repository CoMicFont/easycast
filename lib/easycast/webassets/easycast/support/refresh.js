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
  var failureCount = 0;

  // When the backend respond...
  var handleEvent = function(event, force) {
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

  var onSuccess = function(force) {
    return function(data) {
      failureCount = 0;
      handleEvent({
        type: 'state',
        detail: data,
      }, force);
      setTimeout(pollit, 2500);
    };
  };

  var onError = function(force) {
    return function() {
      console.log("Master lost...");
      failureCount = failureCount+1;
      if (failureCount > 8) {
        splashReconnect();
      } else {
        setTimeout(pollit, 1000);
      }
    };
  };

  function connect() {
    console.log("Connecting to notifications...")
    var backendListener = new EventSource('/notifications');
    backendListener.onmessage = function(e) {
      handleEvent(JSON.parse(e.data));
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
      success: onSuccess(force),
      error: onError(force),
    });
  }
  pollit(true);
}
