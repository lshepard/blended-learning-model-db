/*
 * Initialize the data table options and the initial seed data.
 */
function init_table() {
  
  var options = fetch_data_options();
  options['sErrMode'] = 'throw';

  // Remove the option to choose a pagination length
  options['iDisplayLength'] = 15;
  options['sDom'] = 'pCrtifl'; // this is the default minus "l"ength

  options['oColVis'] = {
    activate: "mouseover",
    aiExclude: [1], // alltext
    buttonText: 'See More Columns',
    iOverlayFade: 0,
  };

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
    var model = table_data[i];

    var title_link = '<a href="' + 
      model['url'] + '">' +
      model['title'] +
      '</a>';

    // this whole section is pretty shitty, would be great to get rid of
    data.push([title_link,
               model['alltext'] ? model['alltext'] : '',
               model['detail'] ? model['detail'] : '', 
               model['hqstate'] ? model['hqstate'] : '',
               model['type'] ? model['type'] : '',
               model['focus'] ? model['focus'] : '',
               model['blendedsubjects'] ? model['blendedsubjects'] : '',
               model['programmodels'] ? model['programmodels'] : '',

               model['postdate'] ? model['postdate'] : '',
               model['hqcity'] ? model['hqcity'] : '',
               model['gradesserved'] ? model['gradesserved'] : '',
               model['frl'] ? model['frl'] : '',
               model['minority'] ? model['minority'] : '',
               model['revenueperpupil'] ? model['revenueperpupil'] : '',

               model['blendedgrades'] ? model['blendedgrades'] : '',
               model['blendedenrollment'] ? model['blendedenrollment'] : '',
               model['content'] ? model['content'] : '',
               model['sis'] ? model['sis'] : '',
               model['othertools'] ? model['othertools'] : '',
               model['indylms'] ? model['indylms'] : '',
               model['indygradebook'] ? model['indygradebook'] : '',
               model['indyassessment'] ? model['indyassessment'] : '',
               model['lmssislink'] ? model['lmssislink'] : ''
               ]);
  }

  var headers = [
                 ];

  return {
    aoColumns: [{'sTitle': 'Model Name'},
                {'sTitle': 'All Text', 'bVisible': false, 'bSearchable': true},
                {'sTitle': 'Detail', 'sWidth': '250px'},
                {'sTitle': 'State', 'bFilterable': true, 'sWidth': '100px'},
                {'sTitle': 'Type', 'bFilterable': true},
                {'sTitle': 'Focus', 'bSortable': false, 'bFilterable': true},
                {'sTitle': 'Subjects', 'bSortable': false, 'bFilterable': true},
                {'sTitle': 'Program Models', 'bSortable': false, 'bFilterable': true},

                {'sTitle': 'Date Posted', 'sType': 'date', 'bVisible': false},
                {'sTitle': 'City', 'bVisible': false},
                {'sTitle': 'Grades Served', 'bVisible': false},
                {'sTitle': '% Free or Reduced Lunch', 'bVisible': false, 'sType': 'formatted-num'},
                {'sTitle': '% Black or Hispanic', 'bVisible': false, 'sType': 'formatted-num'},
                {'sTitle': 'Revenue per Pupil', 'sType': 'formatted-num', 'bVisible': false},

                {'sTitle': 'Blended Grades', 'bVisible': false},
                {'sTitle': 'Blended Enrollment', 'bVisible': false, 'sType': 'formatted-num'},
                {'sTitle': 'Content', 'bVisible': false,'bSortable': false, 'bFilterable': true},
                {'sTitle': 'Student Information System', 'bVisible': false,'bSortable': false, 'bFilterable': true},
                {'sTitle': 'Independent LMS', 'bVisible': false,'bSortable': false, 'bFilterable': true},
                {'sTitle': 'Independent Gradebook Grades', 'bVisible': false,'bSortable': false, 'bFilterable': true},
                {'sTitle': 'Independent Assessment', 'bVisible': false,'bSortable': false, 'bFilterable': true},
                {'sTitle': 'LMS and SIS Link', 'sType': 'formatted-num', 'bVisible': false,'bSortable': false, 'bFilterable': true}
                ],
    aaData: data};
}

