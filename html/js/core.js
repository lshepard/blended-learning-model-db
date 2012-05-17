function init_table() {
  
  var options = fetch_data_options();
  //  options['bPaginate'] = false;
  options['sErrMode'] = 'throw';

  // Remove the option to choose a pagination length
  options['iDisplayLength'] = 15;
  options['sDom'] = 'C<"clear">frtip'; // this is the default minus "l"ength

  var oTable = $('#models').dataTable(options);

  $('#program_models').change(function() { 
    console.log('onchange'); 
    oTable.fnDraw(); 
    });
}

// Convert from the incoming JSON hash
// to the nested array structure that DataTable expects
function fetch_data_options() {
  var data = [];
  for (var i = 0; i < table_data.length; ++i) {
    model = table_data[i];

    var title_link = '<a href="' + 
      model['url'] + '">' +
      model['title'] +
      '</a>';

    data.push([title_link,
               model['detail'] ? model['detail'] : '', 
               model['postdate'] ? model['postdate'] : '',
               model['hqcity'] ? model['hqcity'] : '',
               model['hqstate'] ? model['hqstate'] : '',
               model['type'] ? model['type'] : '',
               model['focus'] ? model['focus'] : '',
               model['gradesserved'] ? model['gradesserved'] : '',
               model['blendedgrades'] ? model['blendedgrades'] : '',
               model['blendedenrollment'] ? model['blendedenrollment'] : '',
               model['blendedsubjects'] ? model['blendedsubjects'] : '',
               model['programmodels'] ? model['programmodels'] : '',
               model['alltext'] ? model['alltext'] : ''
               ]);
  }

  var headers = [
                 ];

  return {
    aoColumns: [{'sTitle': 'Model Name'},
                {'sTitle': 'Detail'},
                {'sTitle': 'Date Posted', 'sType': 'date', 'bVisible': false},
                {'sTitle': 'City', 'bVisible': false},
                {'sTitle': 'State', 'bFilterable': true, 'bSortable': false, 'sWidth': '100px'},
                {'sTitle': 'Type', 'bSortable': false, 'bFilterable': true},
                {'sTitle': 'Focus', 'bSortable': false, 'bFilterable': true},
                {'sTitle': 'Grades Served', 'bVisible': false},
                {'sTitle': 'Grades', 'bVisible': false},
                {'sTitle': 'Blended Enrollment', 'sType': 'formatted-num', 'bVisible': false},
                {'sTitle': 'Subjects', 'bSortable': false, 'bFilterable': true},
                {'sTitle': 'Program Models', 'bSortable': false, 'bFilterable': true},
                {'sTitle': 'All Text', 'bVisible': false, 'bSearchable': true}
                ],
    aaData: data};
}

