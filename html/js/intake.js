function init_form() {
  $("#school_chooser").select2({
    placeholder: {title: "Choose a school", id: ""},
      minimumInputLength: 3,
      ajax: { // instead of writing the function to execute the request we use Select2's convenient helper
        url: "/data/schools.json",
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
      formatResult: schoolFormatResult
          
        //      formatSelection: movieFormatSelection  // omitted for brevity, see the source of this page
        });
}

/*
 * Formats a single school for the form.
 */
function schoolFormatResult(row) {
  var html = [];
  html.push('<b><large>' + row['biz_name'] + '</large></b> <br />');
  html.push('<small>' + row['dist_name'] + ', ' + 
            row['e_city'] + ', ' + row['e_state'] + '</small> <br />');
  html.push('From grade ' + row['grade_low'] + ' to ' + row['grade_high']);

  return html.join('');
}