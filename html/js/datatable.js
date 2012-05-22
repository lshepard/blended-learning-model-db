/*
 * Initialize the data table options and the initial seed data.
 */
function init_table() {
  
  var options = fetch_data_options();
  options['sErrMode'] = 'throw';

  // Remove the option to choose a pagination length
  options['iDisplayLength'] = 10;
  options['sDom'] = 'fCpit'; // this is the default minus "l"ength

  options['oColVis'] = {
    activate: "mouseover",
    aiExclude: [1], // Don't show alltext in the "See more columns" list
    buttonText: 'See More Columns',
    iOverlayFade: 0,
  };

  options['fnDrawCallback'] = function(oSettings) {
    var data = this.fnGetFilteredData();

    // convert the data into an array of meaningful points
    var location_data = 
    this.fnGetFilteredData().map(function(row) {
        // these hard-coded column indices sucks
        return { 
          location: row[8] + ',' + row[2], // city,state - precisely
          title: row[0]
            };
      })

    // defer execution until current call stack is out, to give time
    // for the map to be created
    setTimeout(function () {
      plot_points(location_data);
      },0);
  }

  // create and draw the table
  $('#models').dataTable(options);
}

// Convert from the incoming JSON hash
// to the nested array structure that DataTable expects
function fetch_data_options() {
  var data = [];

  var aoColumns = 
    [{input: 'displaytitle',      sTitle: 'Model', sWidth: '250px'},
     {input: 'alltext',           sTitle: 'All Text', bVisible: false, 'bSearchable': true},
     {input: 'hqstate',           sTitle: 'State', bFilterable: true, sWidth: '100px'},
     {input: 'type',              sTitle: 'Type', bFilterable: true},
     {input: 'focus',             sTitle: 'Focus', bFilterable: true},
     {input: 'blendedsubjects',   sTitle: 'Subjects', bFilterable: true},
     {input: 'programmodels',     sTitle: 'Program Models', bFilterable: true},
     {input: 'postdate',          sTitle: 'Date Posted', 'sType': 'date', bVisible: false},
     {input: 'hqcity',            sTitle: 'City', bVisible: false},
     {input: 'gradesserved',      sTitle: 'Grades Served', bVisible: false},
     {input: 'frl',               sTitle: '% Free or Reduced Lunch', bVisible: false, 'sType': 'formatted-num'},
     {input: 'minority',          sTitle: '% Black/ or Hispanic', bVisible: false, 'sType': 'formatted-num'},
     {input: 'revenueperpupil',   sTitle: 'Revenue per Pupil', 'sType': 'formatted-num', bVisible: false},
     {input: 'blendedgrades',     sTitle: 'Blended Grades', bVisible: false},
     {input: 'blendedenrollment', sTitle: 'Blended Enrollment', bVisible: false, 'sType': 'formatted-num'},
     {input: 'content',           sTitle: 'Content', bVisible: false,bFilterable: true},
     {input: 'sis',               sTitle: 'Student Information System', bVisible: false, bFilterable: true},
     {input: 'othertools',        sTitle: 'Other Tools', bVisible: false, bFilterable: true},
     {input: 'indylms',           sTitle: 'Independent LMS', bVisible: false, bFilterable: true},
     {input: 'indygradebook',     sTitle: 'Independent Gradebook Grades', bVisible: false, bFilterable: true},
     {input: 'indyassessment',    sTitle: 'Independent Assessment', bVisible: false, bFilterable: true},
     {input: 'lmssislink',        sTitle: 'LMS and SIS Link', 'sType': 'formatted-num', bVisible: false, bFilterable: true}
     ];

  for (var i = 0; i < table_data.length; ++i) {
    var model = table_data[i];

    model['displaytitle'] = '<a href="' + 
      model['url'] + '">' +
      model['title'] +
      '</a>';

    if (model['detail']) {
      model['displaytitle'] += '<br />' + model['detail'];
    }

    // go through the column definitions and put the respective columns into their right place
    data.push(aoColumns.map(function(col) { 
          return model[col.input] ? model[col.input] : ''; 
    }));
  }

  return {aoColumns: aoColumns, aaData: data};
}

