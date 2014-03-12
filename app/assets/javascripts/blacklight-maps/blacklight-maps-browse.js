;(function( $ ) {

  $.fn.blacklight_leaflet_map = function(geojson_docs, arg_opts) {
    var map, sidebar, markers, geoJsonLayer;

    // Configure default options and those passed via the constructor options
    var options = $.extend({
      datatype : "placename_coordinates",
      tileurl : 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      mapattribution : 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
      sidebar: 'blacklight-map-sidebar'
    }, arg_opts );

    // Extend options from data-attributes
    $.extend(options, this.data());

    // Display the map
    this.each(function() {

      // Setup Leaflet map
      map = L.map(this.id).setView([0,0], 2);
      L.tileLayer(options.tileurl, {
        attribution: options.mapattribution,
        maxZoom: options.maxzoom
      }).addTo(map);

      // Initialize sidebar
      sidebar = L.control.sidebar(options.sidebar, {
        position: 'right',
        autoPan: false
      });

      // Adds leaflet-sidebar control to map
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
            hideSidebar();
            var placenames = {};
            placenames[feature.properties.placename] = [feature.properties.html];
            offsetMap(e);
            $('#' + options.sidebar).html(buildList(placenames));
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
        hideSidebar();

        //if map is at the lowest zoom level
        if (map.getZoom() === options.maxzoom){

          var placenames = generatePlacenamesObject(e.layer.getAllChildMarkers());


          offsetMap(e);

          //Update sidebar div with new html
          $('#' + options.sidebar).html(buildList(placenames));

          //Show the sidebar!
          sidebar.show();
        }
      });

      //Add click listener to map
      map.on('click drag', hideSidebar);

    });

    // Hides sidebar if it is visible
    function hideSidebar(){
      if (sidebar.isVisible()){
        sidebar.hide();
      }
    }

    // Build the list
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
      var mapWidth = $('#blacklight-map').width();
      var mapHeight = $('#blacklight-map').height();
      if (!e.latlng.equals(map.getCenter())){
        map.panBy([(e.originalEvent.layerX - (mapWidth/4)), (e.originalEvent.layerY - (mapHeight/2))]);
      }else{
        map.panBy([(mapWidth/4), 0]);
      }
    }

  };

}( jQuery ));
