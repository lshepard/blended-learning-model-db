/*
 * This is a bootstrapping JS file, intended to just be loaded on the page with a single div,
 * and it does the rest itself.
 */

/*
 * Compute the domain of the current Javascript file
 * by examining the last script tag added (which must
 * be this one because it's currently executing).
 */
function calculate_js_domain() {
  var scripts = document.getElementsByTagName("script");
  var thisScript = scripts[scripts.length-1];
  js_prefix = thisScript.src.match(/(^https?:\/\/.[^/]+)/)[1];
}
calculate_js_domain(); // must run immediately, if we wait it'll be too late

/*
 * Load the Select2 library as well as accompanying CSS for the intake form.
 */
function load_resources_and_then_init() {
    // dynamically load the two necessary CSS files
    // (ideally these would be packaged in the future)
    $("head").append("<link>"); 
    css = $("head").children(":last"); 
    css.attr({ 
        rel: "stylesheet", 
          type: "text/css", 
          href: js_prefix + "/select2/select2.css" 
          }); 
    
    $("head").append("<link>"); 
    css = $("head").children(":last"); 
    css.attr({ 
        rel: "stylesheet", 
          type: "text/css", 
          href: js_prefix + "/intake/intake.css" 
          }); 

    // Then dynamically load the select2 library,
    // and run the initialization once that's been definitely loaded
    jQuery.getScript(js_prefix + '/select2/select2.js', function() {
        init_select2();
      });

  });

/*
 * Configure and initialize the Select2 attribute itself. Any other initialization should
 * go in here.
 */
function init_select2() {
  $("#school_chooser").select2({
    placeholder: {title: "Choose a school", id: ""},
      minimumInputLength: 3,
      ajax: { // instead of writing the function to execute the request we use Select2's convenient helper

        // TODO: dynamically detect this own domain and load from that, to do prod and test
        // i.e., http://stackoverflow.com/questions/2966941/how-to-get-the-uri-of-the-js-file-itself
        
        url: "http://localhost:5000/data/schools.json",
          dataType: 'jsonp',
          data: function (term, page) {
            return {
              q: term, // search term
              limit: 50,
                };
        },
      results: function (data, page) { // parse the results into the format expected by Select2.
        // since we are using custom formatting functions we do not need to alter remote JSON data
        return {results: data};
        }},
        formatResult: schoolFormatResult,
        });

  $("#school_chooser").on("change", schoolOnChange);

}

/*
 * Helper.
 */
function gradeToString(numeric_grade) {
  if (numeric_grade === -1) {
    return 'PreK'; 
  } else if (numeric_grade === 0) {
    return 'K';
  } else {
    return parseInt(numeric_grade);
  }
}

/*
 * Formats each return row for the dropdown.
 */
function schoolFormatResult(row) {

  var html = [];
  html.push('<div class="results_row">');

  html.push('<span class="entity_name">' + 
            row['name'] + 
            '</span>');

  html.push('<span class="type">' +
            row['display_type'] +
            '</span>');

  html.push('<span class="location">' +
            row['e_city'] + 
            (row['e_state'] ? (', ' + row['e_state']) : '') +
            '</span>');

  if (row['grade_low'] || row['grade_high']) {
    html.push('<span class="grades">' +
              'Grades ' + gradeToString(row['grade_low']) + ' to ' + gradeToString(row['grade_high']) +
              '</span>');
  }

  html.push('</div>');
  return html.join('');
}

/*
 * Once the user makes a selection, this function
 * displays the selection in a better format.
 * (For now, it's just the same, but presumably this
 * would set other values)
 */
function schoolOnChange(e) {
  var row = $('#school_chooser').select2('data');

  var html = [];
  html.push('<div class="results_row">');

  html.push('<span class="entity_name">' + 
            row['name'] + 
            '</span>');

  html.push('<span class="type">' +
            row['display_type'] +
            '</span>');

  html.push('<span class="location">' +
            row['e_city'] + 
            (row['e_state'] ? (', ' + row['e_state']) : '') +
            '</span>');

  if (row['grade_low'] || row['grade_high']) {
    html.push('<span class="grades">' +
              'Grades ' + gradeToString(row['grade_low']) + ' to ' + gradeToString(row['grade_high']) +
              '</span>');
  }

  html.push('</div>');

  $('#school_results').html(html.join(''));
}


$(document).ready( load_resources_and_then_init );
