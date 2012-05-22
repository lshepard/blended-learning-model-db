/*
 * This is stuff generally for the page, not dealing with any of the
 * plugins directly.
 */
function init_ui() {

  // hook up the show / hide animations
  show_hide('Map', $('#show_hide_map'), $('#map_canvas'));
}

function show_hide(name, show_hide_link_div, div_to_control) {

  show_hide_link_div.click(function(el) {
      if (div_to_control.is(":visible")) {
        div_to_control.hide();
        show_hide_link_div.text('Show ' + name);
      } else {
        div_to_control.show();
        show_hide_link_div.text('Hide ' + name);
      }
    });
  
  show_hide_link_div.text('Hide ' + name);
}

// jquery hack from http://stackoverflow.com/questions/920236/jquery-detect-if-selector-returns-null
//$.fn.exists = function () {
//  return this.length !== 0;
//}
