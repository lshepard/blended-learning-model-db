// extensions for custom sorting and filtering

// custom sorting for enrollment
jQuery.fn.dataTableExt.oSort['formatted-num-asc'] = function(a,b) {
  /* Remove any formatting */
  var x = a.match(/\d/) ? a.replace( /[^\d\-\.]/g, "" ) : 0;
  var y = b.match(/\d/) ? b.replace( /[^\d\-\.]/g, "" ) : 0;
      
  /* Parse and return */
  return parseFloat(x) - parseFloat(y);
};
jQuery.fn.dataTableExt.oSort['formatted-num-desc'] = function(a,b) {
  var x = a.match(/\d/) ? a.replace( /[^\d\-\.]/g, "" ) : 0;
  var y = b.match(/\d/) ? b.replace( /[^\d\-\.]/g, "" ) : 0;
      
  return parseFloat(y) - parseFloat(x);
};

function initFilteredColumn(oSettings, iColumn) {
  if (!oSettings.aoColumns[iColumn].filterSelect) {

    var allValues = {};
    
    for (var iRow = 0; iRow < oSettings.aoData.length; ++iRow) {
      var value = oSettings.aoData[iRow]._aData[iColumn];
      var values = value.split(',');
      for (var i = 0; i < values.length; ++i) {
        var value = values[i];
        // normalize
        value = value.replace(/^\s+|\s+$/g,"").toLowerCase();
        allValues[value] = values[i];
      }
    }
    
    // okay, allValues now contains the desired contents of the <select>
    
    // create a Select
    var select = $('<select multiple="multiple"/>');
    for (var key in allValues) {
      select.append(new Option(allValues[key], key, true, true));
    }

    // register redrawing
    select.change(function() { oSettings.oInstance.fnDraw(); });

    var container = $('<div class="ui-multiselect"/>');
    container.append(select);
    $(oSettings.aoColumns[iColumn].nTh).append(container);
    
    select.multiselect({header: true,
          selectedList: 0,
          selectedText: "",
          noneSelectedText: "",
          checkAllText: "All",
          uncheckAllText: "None",
          height: "auto"});

    // now that it's created, append it to the column header
    oSettings.aoColumns[iColumn].filterSelect = select;
  }
} 

// add filter dropdown here
// this code is terrible as of yet
$.fn.dataTableExt.afnFiltering.push
  (
   function (oSettings, aData, iDataIndex) {
     for (var iColumn = 0; iColumn < oSettings.aoColumns.length; ++iColumn) {
       // check to see if the column supports this
       columnSettings = oSettings.aoColumns[iColumn];

       if (!columnSettings.bFilterable) {
         continue;
       }

       initFilteredColumn(oSettings, iColumn);
       
       // pull the dropdown reference from the config
       var options = oSettings.aoColumns[iColumn].filterSelect[0].options;
       
       // get an object with keys for each comma-delimited element here
       // n^2 algo but each one should be really small so no big deal
       var potential_matches = aData[iColumn].split(',');
       
       var passedThisRound = true;
       for (var i = 0; i < options.length; ++i) {
         if (options[i].selected) {
           passedThisRound = false;
           // now look through all the objects in split
           for (var j = 0; j < potential_matches.length; ++j) {
             if (potential_matches[j].toLowerCase().indexOf(options[i].value) != -1) {
               passedThisRound = true;
               break;
             }
           }
           if (passedThisRound) {
             break;
           }
         }
       }
       if (passedThisRound) {
         continue;
       } else {
         console.log("rejected with ", potential_matches, aData);
         return false;
       }
     }
     console.log("returning true");
     return true;
   });
