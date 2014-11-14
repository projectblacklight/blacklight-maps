module BlacklightMaps

  # This class provides the ability to export a response document to GeoJSON.
  # The export is formated as a GeoJSON FeatureCollection, where the features
  # consist of an array of Point features.  For more on the GeoJSON
  # specification see http://geojson.org/geojson-spec.html.
  #
  class GeojsonExport
    include BlacklightMaps

    #require 'geohash'

    # controller is a Blacklight CatalogController object passed by a helper
    # action is the controller action
    # response_docs is passed by a helper, and is either:
    #  - index view: an array of facet values
    #  - show view: the document object
    def initialize(controller, action, response_docs)
      @controller = controller
      @action = action
      @response_docs = response_docs
    end

    def to_geojson
      geojson_docs = { type: 'FeatureCollection',
                       features: build_geojson_features }
      geojson_docs.to_json
    end

    private

    def blacklight_maps_config
      @controller.blacklight_config.view.maps
    end

    def geojson_field
      blacklight_maps_config.geojson_field
    end

    def coordinates_field
      blacklight_maps_config.coordinates_field
    end

    def search_mode
      blacklight_maps_config.search_mode
    end

    def facet_mode
      blacklight_maps_config.facet_mode
    end

    def placename_property
      blacklight_maps_config.placename_property
    end

    def build_geojson_features
      features = []
      case @action
        when "index"
          @response_docs.each do |geofacet|
            if facet_mode == "coordinates"
              #features.push(build_feature_from_geohash(geofacet.value))
              features.push(build_feature_from_coords(geofacet.value))
            else
              features.push(build_feature_from_geojson(geofacet.value))
            end
          end
        when "show"
          doc = @response_docs
          return if doc[geojson_field].nil? && doc[coordinates_field].nil?
          if doc[geojson_field]
            doc[geojson_field].uniq.each do |loc|
              features.push(build_feature_from_geojson(loc))
            end
          elsif doc[coordinates_field]
            doc[coordinates_field].uniq.each do |coords|
              features.push(build_feature_from_coords(coords))
            end
          end
      end
      features
    end
=begin
    # don't need if location_rpt can't be faceted properly
    def build_feature_from_geohash(geohash)
      geojson_hash = {"type" => "Feature", "geometry" => {"type" => "Point"}, "properties" => {}}
      coords = GeoHash.decode(geohash)
      if coords[0].class == Float # point
        #puts "GEOHASH = " + geohash + "; DECODED = " + coords.inspect
        geojson_hash["geometry"]["coordinates"] = coords.reverse
      elsif coords[0].class == Array # bbox
        # TODO: figure out how Solr geohashes bboxes
        #puts "GEOHASH = " + geohash + "; DECODED = " + coords.inspect
        #geojson_hash["bbox"] = coords
      end
      geojson_hash["properties"]["popup"] = render_leaflet_popup_content(geojson_hash)
      geojson_hash
    end
=end
    def build_feature_from_geojson(loc)
      geojson_hash = JSON.parse(loc)
      # turn bboxes into points for index view so we don't get weird mix of boxes and markers
      if @action == "index" && geojson_hash["bbox"]
        geojson_hash["geometry"]["coordinates"] = Geometry::BoundingBox.new(geojson_hash["bbox"]).find_center
        geojson_hash["geometry"]["type"] = "Point"
        geojson_hash.delete("bbox")
      end
      geojson_hash["properties"] ||= {}
      geojson_hash["properties"]["popup"] = render_leaflet_popup_content(geojson_hash)
      geojson_hash
    end

    def build_feature_from_coords(coords)
      geojson_hash = {"type" => "Feature", "geometry" => {}, "properties" => {}}
      if coords.scan(/[\s]/).length == 3 # bbox
        if @action == "index"
          geojson_hash["geometry"]["type"] = "Point"
          geojson_hash["geometry"]["coordinates"] = Geometry::BoundingBox.from_lon_lat_string(coords).find_center
        else
          coords_array = coords.split(' ').map { |v| v.to_f }
          geojson_hash["bbox"] = coords_array
          geojson_hash["geometry"]["type"] = "Polygon"
          geojson_hash["geometry"]["coordinates"] = [[[coords_array[0],coords_array[1]],
                                                    [coords_array[2],coords_array[1]],
                                                    [coords_array[2],coords_array[3]],
                                                    [coords_array[0],coords_array[3]],
                                                    [coords_array[0],coords_array[1]]]]
        end
      elsif coords.match(/^[-]?[\d]+[\.]?[\d]*[ ,][-]?[\d]+[\.]?[\d]*$/) # point
        geojson_hash["geometry"]["type"] = "Point"
        if coords.match(/,/)
          coords_array = coords.split(',').reverse
        else
          coords_array = coords.split(' ')
        end
        geojson_hash["geometry"]["coordinates"] = coords_array.map { |v| v.to_f }
      else
        Rails.logger.error("This coordinate format is not yet supported: '#{coords}'")
      end
      geojson_hash["properties"] = { popup: render_leaflet_popup_content(geojson_hash.stringify_keys) }
      geojson_hash
    end

    # Render to string the partial for each individual doc.
    # For placename facet searching, render catalog/map_facet_search partial,
    # full geojson hash is passed to the partial for easier local customization
    # For coordinate searches (or features with only coordinate data),
    # render catalog/map_coordinate_search partial
    def render_leaflet_popup_content(geojson_hash)
      if search_mode == 'placename_facet' && geojson_hash["properties"][placename_property]
        @controller.render_to_string partial: 'catalog/map_facet_search',
                                     locals: { placename: geojson_hash["properties"][placename_property],
                                               geojson_hash: geojson_hash }
      else
        @controller.render_to_string partial: 'catalog/map_coordinate_search',
                                     locals: { coordinates: geojson_hash["bbox"].presence || geojson_hash["geometry"]["coordinates"] }
      end

    end

=begin
    def build_geojson_features
      case type
      when 'placename_coord'
        build_placename_coord_features
      when 'bbox'
        build_bbox_features
      else
        Rails.logger.error("Your Solr field type was not configured with a recognized type, '#{type}' is not yet supported")
      end
    end

    # Builds the features structure for placename_coord type documents
    def build_placename_coord_features
      features = []
      @response_docs.each do |doc|
        next if doc[placename_coord_field].nil?
        doc[placename_coord_field].uniq.each do |loc|
          values = loc.split(placename_coord_delimiter)
          features.push(
            build_point_feature(values[2], values[1],
                                name: values[0],
                                html: render_leaflet_sidebar_partial(doc)))
        end
      end
      features
    end

    # Builds the features structure for bbox type documents
    def build_bbox_features
      features = []
      @response_docs.each do |doc|
        next if doc[bbox_field].nil?
        doc[bbox_field].uniq.each do |loc|
          lnglat = Geometry::BoundingBox.from_lon_lat_string(loc).find_center
          features.push(
            build_point_feature(lnglat[0], lnglat[1],
                                html: render_leaflet_sidebar_partial(doc)))
        end
      end
      features
    end


    # Build the individual feature which is added to the FeatureCollection.
    # lng is the longitude of the feature
    # lat is the latitude of the feature
    # *args additional arguments can be passed to the feature, these arguments
    # will be reflected in the 'properties' member.
    # html: "html string to show up" must be passed for the sidebar to display
    # list items
    def build_point_feature(lng, lat, *args)
      properties = args.extract_options!
      feature = { type: 'Feature',
                  geometry: {
                    type: 'Point',
                    coordinates: [lng.to_f, lat.to_f] },
                  properties: properties }
      feature
    end
=end
  end
end
