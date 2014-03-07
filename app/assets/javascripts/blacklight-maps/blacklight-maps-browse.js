
var map, sidebar;

Blacklight.onLoad(function() {

  // Stop doing stuff if the map div isn't there
  if ($("#map").length === 0){
    return;
  }
  
  // Get the configuration options from the data-attributes
  $.extend(Blacklight.mapOptions, $("#map").data());

  map = L.map('map').setView([0,0], 2);
  L.tileLayer(Blacklight.mapOptions.tileurl, {
    attribution: Blacklight.mapOptions.attribution,
    maxZoom: Blacklight.mapOptions.maxzoom
  }).addTo(map);

  //Sets up leaflet-sidebar
  sidebar = L.control.sidebar('leaflet-sidebar', {
    position: 'right',
    autoPan: false
  });

  //Adds leaflet-sidebar control to map (object)
  map.addControl(sidebar);

  //Create a marker cluster object and set options
  markers = new L.MarkerClusterGroup({
    showCoverageOnHover: false,
    spiderfyOnMaxZoom: false,
    singleMarkerMode: true,
    animateAddingMarkers: true
  });

  //Iterate through document looking for location values for the map
  if (docs.length > 0){
    $.each(docs, function(i,val){
      if (val[Blacklight.mapOptions.latlngfield]){
        
        //Look through the location field 'geoloc' to add multiple values for each document
        $.each(val[Blacklight.mapOptions.latlngfield], function(j,loc){

          //Parse the string to JSON lat/lng array
          latlng = JSON.parse(loc);

          title = val[Blacklight.mapOptions.placefield][j];

          //Add marker to marker cluster object
          markers.addLayer(createMarker(latlng, title));
        });
      }
    });
  }

  //Add marker cluster object to map
  map.addLayer(markers);

  markers.on('clusterclick', function(e){
      
    //hide sidebar if it is visible
    if (sidebar.isVisible()){
      sidebar.hide();
    }

    //if map is at the lowest zoom level
    if (map.getZoom() === Blacklight.mapOptions.maxzoom){

      //get the title from the markers inside of the markercluster object
      var titles = [];// = e.layer._markers[0].options.title;
      $.each(e.layer._markers, function(i,val){
        // console.log(val.options.title)
        if ($.inArray(val.options.title, titles) === -1 ){
          titles.push(val.options.title);
        }
      });
      //build the results list sidebar
      html = "";
      $.each(titles, function(i,val){
        html += "<h2>" + val + "</h2>";
        html += buildList(val);
      });

      //Move the map so that it centers the clicked cluster TODO account for various size screens
      mapWidth = $('#map').width();
      mapHeight = $('#map').height();
      map.panBy([(e.originalEvent.layerX - (mapWidth/4)), (e.originalEvent.layerY - (mapHeight/2))]);
      
      //Update sidebar div with new html
      $('#leaflet-sidebar').html(html);

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
  attribution : 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
};

function createMarker(latlng, title){
  return new L.Marker(latlng, {title: title}).on('click', function(e){
    //hide the sidebar if it is visible
    if (sidebar.isVisible()){
      sidebar.hide();
    }
    var list = buildList(title);
    mapWidth = $('#map').width();
    mapHeight = $('#map').height();
    map.panBy([(e.originalEvent.layerX - (mapWidth/4)), (e.originalEvent.layerY - (mapHeight/2))]);
    $('#leaflet-sidebar').html("<h2>" + title + "</h2>" + list);
    sidebar.show();
  });
}

function buildList(title){
  var list = "<div><ul class='media-list'>";
  $.each(docs, function(i,val){
    if ($.inArray(title, val[Blacklight.mapOptions.placefield]) !== -1){
      if (Blacklight.mapOptions.thumbfield){
        list += "<li class='media'><a class='pull-left' href='#'><img class='media-object sidebar-thumb' src='" + val[Blacklight.mapOptions.thumbfield] + "'></a><div class='media-body'><h4 class='media-heading'><a href='" + Blacklight.mapOptions.docurl + val[Blacklight.mapOptions.docid] + "'>" + val[Blacklight.mapOptions.titlefield] + "</a></h4></div></li>";
      }else{
        list += "<li class='media'><div class='media-body'><h4 class='media-heading'><a href='" + Blacklight.mapOptions.docurl + val[Blacklight.mapOptions.docid] + "'>" + val[Blacklight.mapOptions.titlefield] + "</a></h4></div></li>";
      }
    }
  });
  list += "</ul></div>";
  return list;
}