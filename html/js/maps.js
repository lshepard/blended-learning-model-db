var map;
var infoWindow;
 
function init_map() {
  var myOptions = {
    center: new google.maps.LatLng(38, -97.7372),
    zoom: 4,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  map = new google.maps.Map(document.getElementById("map_canvas"),
                                myOptions);

  infoWindow = new google.maps.InfoWindow();

  plot_schools();
}

// populate all the points on the map from the database table

// go through the db, geocode and plot them on a map
function plot_schools() {
  // start with just the whole data set. we'll go to the currently visible in a bit.
  var location_model_mapping = {};

  for (var i = 0; i < table_data.length; ++i) {
    var model = table_data[i];
    var location_name = model['hqcity'] + ',' + model['hqstate'];
    if (!location_model_mapping[location_name]) {
      location_model_mapping[location_name] = [];
    }
    location_model_mapping[location_name].push(model);
  }


  for (var location_name in location_model_mapping) {
    var location = locations[location_name];
    if (!location) {
      console.error("Missing geocode info for" , model);
      continue;
    }

    var content = "<h3>" + location_name + "</h3>";
    var models = location_model_mapping[location_name];
    for (var i = 0; i < models.length; ++i) {
      var model = models[i];
      content = content + "<p>" + model['title'] + "</p>";
    }


    var latLng = new google.maps.LatLng(location.lat,
                                        location.lng);
    make_marker(latLng, content);
  }
}

function make_marker(latLng, content) {
  var marker = new google.maps.Marker({position: latLng,
                                       map:map});
  
  google.maps.event.addDomListener(marker, "click", function() {
      infoWindow.setContent(content);
      infoWindow.open(map, marker);
    });
}
