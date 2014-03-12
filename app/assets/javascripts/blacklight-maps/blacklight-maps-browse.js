var map, sidebar;

Blacklight.onLoad(function() {

  // Stop doing stuff if the map div isn't there
  if ($("#blacklight-map").length === 0){
    return;
  }
  
  // Get the configuration options from the data-attributes
  $.extend(Blacklight.mapOptions, $("#blacklight-map").data());

  map = L.map('blacklight-map').setView([0,0], 2);
  L.tileLayer(Blacklight.mapOptions.tileurl, {
    attribution: Blacklight.mapOptions.mapattribution,
    maxZoom: Blacklight.mapOptions.maxzoom
  }).addTo(map);

  // Sets up leaflet-sidebar
  sidebar = L.control.sidebar('blacklight-map-sidebar', {
    position: 'right',
    autoPan: false
  });

  // Adds leaflet-sidebar control to map (object)
  map.addControl(sidebar);

  // Create a marker cluster object and set options
  markers = new L.MarkerClusterGroup({
    showCoverageOnHover: false,
    spiderfyOnMaxZoom: false,
    singleMarkerMode: true,
    animateAddingMarkers: true
  });

  geoJsonLayer = L.geoJson(geojson_docs, {
    onEachFeature: function(feature, layer){
      layer.defaultOptions.title = feature.properties.placename;
      layer.on('click', function(e){
        if (sidebar.isVisible()){
            sidebar.hide();
        }
        var placenames = {};
        placenames[feature.properties.placename] = [feature.properties.html];
        offsetMap(e);
        $('#blacklight-map-sidebar').html(buildList(placenames));
        sidebar.show();
      });
    }
  });

  // Add GeoJSON layer to marker cluster object
  markers.addLayer(geoJsonLayer);

  // Add marker cluster object to map
  map.addLayer(markers);

  // Listeners for marker cluster clicks
  markers.on('clusterclick', function(e){
      
    //hide sidebar if it is visible
    if (sidebar.isVisible()){
      sidebar.hide();
    }

    //if map is at the lowest zoom level
    if (map.getZoom() === Blacklight.mapOptions.maxzoom){

      var placenames = generatePlacenamesObject(e.layer._markers);
      

      offsetMap(e);

      //Update sidebar div with new html
      $('#blacklight-map-sidebar').html(buildList(placenames));

      //Show the sidebar!
      sidebar.show();
    }
  });

  //Add click listener to map
  map.on('click', function(e){

    //hide the sidebar if it is visible
    if (sidebar.isVisible()){
      sidebar.hide();
    }
  });

  //drag listener on map
  map.on('drag', function(e){

    //hide the sidebar if it is visible
    if (sidebar.isVisible()){
      sidebar.hide();
    }
  });

});

Blacklight.mapOptions = {
  tileurl : 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  mapattribution : 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
};

function buildList(placenames){
  var html = "";
  $.each(placenames, function(i,val){
    html += "<h2>" + i + "</h2>";
    html += "<ul class='sidebar-list'>";
    $.each(val, function(j, val2){
      html += val2;
    });
    html += "</ul>";
  });
  return html;
}

// Generates placenames object 
function generatePlacenamesObject(markers){
  var placenames = {};
  $.each(markers, function(i,val){
    if (!(val.feature.properties.placename in placenames)){
      placenames[val.feature.properties.placename] = [];
    }
    placenames[val.feature.properties.placename].push(val.feature.properties.html);
  });
  return placenames;
}

// Move the map so that it centers the clicked cluster TODO account for various size screens
function offsetMap(e){
  mapWidth = $('#blacklight-map').width();
  mapHeight = $('#blacklight-map').height();
  if (!e.latlng.equals(map.getCenter())){
    map.panBy([(e.originalEvent.layerX - (mapWidth/4)), (e.originalEvent.layerY - (mapHeight/2))]);
  }else{
    map.panBy([(mapWidth/4), 0]);
  }
}