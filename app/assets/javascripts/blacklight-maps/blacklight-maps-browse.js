;(function( $ ) {

  $.fn.blacklight_leaflet_map = function(geojson_docs, arg_opts) {
    var map, sidebar, markers, geoJsonLayer, currentLayer;

    // Update page links with number of mapped items
    $(this.selector).before('<span class="badge mapped-count">' + geojson_docs.features.length + '</span> mapped');

    // Configure default options and those passed via the constructor options
    var options = $.extend({
      tileurl : 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      mapattribution : 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
      viewpoint: [0,0],
      initialzoom: 2,
      sidebar: 'blacklight-map-sidebar'
    }, arg_opts );

    // Extend options from data-attributes
    $.extend(options, this.data());

    // Display the map
    this.each(function() {
      options.id = this.id;

      // Setup Leaflet map
      map = L.map(this.id).setView(options.viewpoint, options.initialzoom);
      L.tileLayer(options.tileurl, {
        attribution: options.mapattribution,
        maxZoom: options.maxzoom
      }).addTo(map);

      /*
      // Initialize sidebar
      sidebar = L.control.sidebar(options.sidebar, {
        position: 'right',
        autoPan: false
      });

      // Adds leaflet-sidebar control to map
      map.addControl(sidebar);
      */

      /*
      // Create a marker cluster object and set options
      markers = new L.MarkerClusterGroup({
        showCoverageOnHover: false,
        spiderfyOnMaxZoom: true,
        singleMarkerMode: true,
        animateAddingMarkers: true
      });
      */

      geoJsonLayer = L.geoJson(geojson_docs, {
        onEachFeature: function(feature, layer){
            if (feature.properties.popup) {
                layer.bindPopup(feature.properties.popup);
            } else {
                layer.bindPopup("Sorry, there is no data for this location.");
            }

          /*
          layer.defaultOptions.title = getMapTitle(options.type, feature.properties.name);
          layer.on('click', function(e){
            var placenames = {};
            placenames[layer.defaultOptions.title] = [feature.properties.html];
            setupSidebarDisplay(e,placenames);
          });
          */

        }
      });

      // Add GeoJSON layer to marker cluster object
      // markers.addLayer(geoJsonLayer);

      // Add GeoJSON layer object to map
      map.addLayer(geoJsonLayer);

      // Listeners for marker cluster clicks
      markers.on('clusterclick', function(e){
        // hideSidebar();

        //if map is at the lowest zoom level
        if (map.getZoom() === options.maxzoom){

          var placenames = generatePlacenamesObject(e.layer.getAllChildMarkers());
          setupSidebarDisplay(e,placenames);
        }
      });

      //Add click listener to map
      // map.on('click drag', hideSidebar);

    });

    function setupSidebarDisplay(e, placenames){
      hideSidebar();
      offsetMap(e);
      if (currentLayer !== e.layer || !("layer" in e)){
        // Update sidebar div with new html
        $('#' + options.sidebar).html(buildList(placenames));

        // Scroll sidebar div to top
        $('#' + options.sidebar).scrollTop(0);
        currentLayer = e.layer;
      }

      // Show the sidebar
      sidebar.show();

    }

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
        if (!(val.defaultOptions.title in placenames)){
          placenames[val.defaultOptions.title] = [];
        }
        placenames[val.defaultOptions.title].push(val.feature.properties.html);
      });
      return placenames;
    }

    // Move the map so that it centers the clicked cluster TODO account for various size screens
    function offsetMap(e){
      var mapWidth = $('#' + options.id).width();
      var mapHeight = $('#' + options.id).height();
      if (!e.latlng.equals(map.getCenter())){
        map.panBy([(e.originalEvent.layerX - (mapWidth/4)), (e.originalEvent.layerY - (mapHeight/2))]);
      }else{
        map.panBy([(mapWidth/4), 0]);
      }
    }

  };

  function getMapTitle(type, featureName){
    switch(type){
    case 'bbox':
      return 'Results';
    case 'placename_coord':
      return featureName;
    default:
      return 'Results';
    }
  }

}( jQuery ));
