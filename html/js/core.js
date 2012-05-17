function init_table() {
  
  var options = fetch_data_options();
  //  options['bPaginate'] = false;
  options['sErrMode'] = 'throw';

  // Remove the option to choose a pagination length
  options['iDisplayLength'] = 20;
  options['sDom'] = 'frtip'; // this is the default minus "l"ength
  
  var oTable = $('#models').dataTable(options);
  $('#program_models').
    multiselect({header: false,
                 selectedList: 3,
          noneSelectedText: "",
          checkAllText: "All",
          uncheckAllText: "None",
          height: "auto"});

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
               model['programmodels'] ? model['programmodels'] : ''
               ]);
  }

  var headers = [
                 ];

  return {
    aoColumns: [{'sTitle': 'Model Name'},
                {'sTitle': 'Detail'},
                {'sTitle': 'Date Posted', 'sType': 'date'},
                {'sTitle': 'City'},
                {'sTitle': 'State'},
                {'sTitle': 'Type'},
                {'sTitle': 'Focus'},
                {'sTitle': 'Grades Served'},
                {'sTitle': 'Blended Grades'},
                {'sTitle': 'Blended Enrollment'},
                {'sTitle': 'Blended Subjects'},
                {'sTitle': 'Program Models'}
                ],
    aaData: data};
}

// Modified filtering plugins pulled from http://datatables.net/plug-ins/filtering

$.fn.dataTableExt.afnFiltering.push
  (
   function (oSettings, aData, iDataIndex) {
     var oSelect = document.getElementById('program_models');
     var iColumn = 11;

     console.log("custom filter on ", aData[iColumn].split(','));

     // get an object with keys for each comma-delimited element here
     // n^2 algo but each one should be really small so no big deal
     var potential_matches = aData[iColumn].split(',');

     var nothingSelected = true;
     for (var i = 0; i < oSelect.options.length; ++i) {
       if (oSelect.options[i].selected) {
         nothingSelected = false;
         // now look through all the objects in split
         for (var j = 0; j < potential_matches.length; ++j) {
           if (potential_matches[j].indexOf(oSelect.options[i].value) != -1) {
             return true;
           }
         }
       }
     }

     return nothingSelected; // default to all if nothing is selected
   });
