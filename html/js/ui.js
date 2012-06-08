/*
 * This is stuff generally for the page, not dealing with any of the
 * plugins directly.
 */
function init_ui() {
  $('#tabs').tabs();

  $('#tabs').bind('tabsshow', function(event, ui) {
    console.log("attempting to resize");
    if (ui.panel.id == "tabs-2") {
      resize_map();
    }
  });
}