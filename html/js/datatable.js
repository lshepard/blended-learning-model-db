var colNumLookup = {};
var aoColumns; // global is terrible but needd for fnCreatedRow for now

/*
 * Initialize the data table options and the initial seed data.
 */
function init_table() {
  
  var options = fetch_data_options();
  options['sErrMode'] = 'throw';

  // Remove the option to choose a pagination length
  options['iDisplayLength'] = 10;
  options['sDom'] = 'tpi'; // this is the default minus "l"ength
  options['bAutoWidth'] = false;

  options['fnDrawCallback'] = fnDrawCallback;
  options['fnCreatedRow'] = fnCreatedRow;

  // create and draw the table
  $('#models').dataTable(options);
}

// Convert from the incoming JSON hash
// to the nested array structure that DataTable expects
function fetch_data_options() {
  var data = [];

  aoColumns =
    [{input: 'title',             sTitle: 'Model', sWidth: '250px'},
     {input: 'detail',            sTitle: 'Detail'},
     {input: 'url',               sTitle: 'URL'},
     {input: 'hqstate',           sTitle: 'State', bFilterable: true, sWidth: '100px'},
     {input: 'type',              sTitle: 'Type', bFilterable: true},
     {input: 'focus',             sTitle: 'Focus', bFilterable: true},
     {input: 'blendedsubjects',   sTitle: 'Blended subjects', bFilterable: true},
     {input: 'programmodels',     sTitle: 'Blended-learning model', bFilterable: true},
     {input: 'postdate',          sTitle: 'Date Posted', 'sType': 'date'},
     {input: 'hqcity',            sTitle: 'City'},
     {input: 'gradesserved',      sTitle: 'Grades Served'},
     {input: 'frl',               sTitle: '% Free or Reduced Lunch', 'sType': 'formatted-num'},
     {input: 'minority',          sTitle: '% Black/ or Hispanic', 'sType': 'formatted-num'},
     {input: 'revenueperpupil',   sTitle: 'Revenue per Pupil', 'sType': 'formatted-num'},
     {input: 'blendedgrades',     sTitle: 'Blended Grades'},
     {input: 'blendedenrollment', sTitle: 'Blended Enrollment', 'sType': 'formatted-num'},
     {input: 'content',           sTitle: 'Content',bFilterable: true},
     {input: 'sis',               sTitle: 'Student Information System', bFilterable: true},
     {input: 'othertools',        sTitle: 'Other Tools', bFilterable: true},
     {input: 'indylms',           sTitle: 'Independent LMS', bFilterable: true},
     {input: 'indygradebook',     sTitle: 'Independent Gradebook Grades', bFilterable: true},
     {input: 'indyassessment',    sTitle: 'Independent Assessment', bFilterable: true},
     {input: 'lmssislink',        sTitle: 'LMS and SIS Link', 'sType': 'formatted-num', bFilterable: true}
     ];

  // generate a reverse map from name to index
  for (var i = 0; i < aoColumns.length; ++i) {
    colNumLookup[aoColumns[i].input] = i;
  }

  for (var i = 0; i < table_data.length; ++i) {
    var model = table_data[i];

    // go through the column definitions and put the respective columns into their right place
    data.push(aoColumns.map(function(col) { 
          return model[col.input] ? model[col.input] : ''; 
    }));
  }

  return {aoColumns: aoColumns, aaData: data};
}

/*
 * Automatically invoked every time the table is drawn - both on first draw
 * as well as in response to filters.
 */
function fnDrawCallback(oSettings) {
  var data = this.fnGetFilteredData();
  
  // convert the data into an array of meaningful points
  var location_data = 
    this.fnGetFilteredData().map(function(row) {
        // these hard-coded column indices sucks
        return { 
          location: row[colNumLookup['hqcity']] + ',' + row[colNumLookup['hqstate']], // city,state - precisely
          title: row[0]
        };
      });
    
  // defer execution until current call stack is out, to give time
  // for the map to be created
  setTimeout(function () {
      plot_points(location_data);
    },0);
}

/*
 * This is called after each row is rendered. Basically, we trash the existing
 * columns and custom render a new row more conducive to a list-view.
 * CSS is used to hide the remaining columns.
 */
function fnCreatedRow( nRow, aData, iDataIndex ) {
  // private helper function to avoid hard-coding column indices
  function v(field) {
    return aData[colNumLookup[field]];
  }

  var html = [];

  // title
  html.push('<div class="model_row">');
  
  // location
  html.push('<span class="location">' + v('hqcity') + ', ' + v('hqstate') + '</span>');

  html.push('<h2>' +
            '<a href="' + v('url') + '">' + v('title') + '</a>' +
            '</h2>');

  html.push('<span class="model">' + v('programmodels') + '</span>');

  html.push('<span class="grades"> Grades ' + v('blendedgrades') + '</span>');

  //  html.push('<p>' + v('modeldescription') + '</p>');
  html.push('<p> The face-to-face teacher never lectures. Students choose from a menu of online and other options for learning. Many students use online programs for certain subjects, with a face-to-face teacher providing as-needed help. </p>');

  html.push('</div>');
    
  // set it just to the first td in the row
  $('td:eq(0)', nRow).empty().html(html.join(''));

}
