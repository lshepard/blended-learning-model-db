/*
 * This is stuff generally for the page, not dealing with any of the
 * plugins directly.
 */
function init_ui() {
  $('#tabs').tabs();

  var mapHasBeenInitialized = false;

  $('#tabs').bind('tabsshow', function(event, ui) {
    if (ui.panel.id == "tabs-2") {
      if (!mapHasBeenInitialized) {
        init_map();
        datatable.fnDraw();
        mapHasBeenInitialized = true;
      }
      resize_map();
    }
  });

  $('a.button').button();
}
