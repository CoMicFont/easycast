/**
 * Callback used on refresh() on display pages.
 *
 * This callback refreshes the page the hard way, by forcing
 * the location to change.
 */
function refreshDisplay(current, register){
  window.location = window.location;
}
