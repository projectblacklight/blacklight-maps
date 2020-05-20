# frozen_string_literal: true

module BlacklightMaps

  # This class provides the ability to export a response document to GeoJSON.
  # The export is formated as a GeoJSON FeatureCollection, where the features
  # consist of an array of Point features.  For more on the GeoJSON
  # specification see http://geojson.org/geojson-spec.html.
  #
  class GeojsonExport
    include BlacklightMaps

    # controller is a Blacklight CatalogController object passed by a helper
    # action is the controller action
    # response_docs is passed by a helper, and is either:
    #  - index view, map view: an array of facet values
    #  - show view: the document object
    # options is an optional hash of possible configuration options
    def initialize(controller, action, response_docs, options={})
      @controller = controller
      @action = action
      @response_docs = response_docs
      @options = options
    end

    # build the GeoJSON FeatureCollection
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

    # build GeoJSON features array
    # determine how to build GeoJSON feature based on config and controller#action
    def build_geojson_features
      features = []
      case @action
      when "index", "map"
        @response_docs.each do |geofacet|
          if facet_mode == "coordinates"
            features.push(build_feature_from_coords(geofacet.value, geofacet.hits))
          else
            features.push(build_feature_from_geojson(geofacet.value, geofacet.hits))
          end
        end
      when "show"
        doc = @response_docs
        return unless doc[geojson_field] || doc[coordinates_field]

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

    # build blacklight-maps GeoJSON feature from GeoJSON-formatted data
    # turn bboxes into points for index view so we don't get weird mix of boxes and markers
    def build_feature_from_geojson(loc, hits = nil)
      geojson_hash = JSON.parse(loc).deep_symbolize_keys
      if @action != "show" && geojson_hash[:bbox]
        geojson_hash[:geometry][:coordinates] = Geometry::Point.new(Geometry::BoundingBox.new(geojson_hash[:bbox]).find_center).normalize_for_search
        geojson_hash[:geometry][:type] = "Point"
        geojson_hash.delete(:bbox)
      end
      geojson_hash[:properties] ||= {}
      geojson_hash[:properties][:hits] = hits.to_i if hits
      geojson_hash[:properties][:popup] = render_leaflet_popup_content(geojson_hash, hits)
      geojson_hash
    end

    # build blacklight-maps GeoJSON feature from coordinate data
    # turn bboxes into points for index view so we don't get weird mix of boxes and markers
    def build_feature_from_coords(coords, hits = nil)
      geojson_hash = {type: "Feature", geometry: {}, properties: {}}
      if coords.scan(/[\s]/).length == 3 # bbox
        if @action != "show"
          geojson_hash[:geometry][:type] = "Point"
          geojson_hash[:geometry][:coordinates] = Geometry::Point.new(Geometry::BoundingBox.from_lon_lat_string(coords).find_center).normalize_for_search
        else
          coords_array = coords.split(' ').map { |v| v.to_f }
          geojson_hash[:bbox] = coords_array
          geojson_hash[:geometry][:type] = "Polygon"
          geojson_hash[:geometry][:coordinates] = [[[coords_array[0],coords_array[1]],
                                                    [coords_array[2],coords_array[1]],
                                                    [coords_array[2],coords_array[3]],
                                                    [coords_array[0],coords_array[3]],
                                                    [coords_array[0],coords_array[1]]]]
        end
      elsif coords.match(/^[-]?[\d]*[\.]?[\d]*[ ,][-]?[\d]*[\.]?[\d]*$/) # point
        geojson_hash[:geometry][:type] = "Point"
        if coords.match(/,/)
          coords_array = coords.split(',').reverse
        else
          coords_array = coords.split(' ')
        end
        geojson_hash[:geometry][:coordinates] = coords_array.map { |v| v.to_f }
      else
        Rails.logger.error("This coordinate format is not yet supported: '#{coords}'")
      end
      geojson_hash[:properties] = { popup: render_leaflet_popup_content(geojson_hash, hits) } if geojson_hash[:geometry][:coordinates]
      geojson_hash[:properties][:hits] = hits.to_i if hits
      geojson_hash
    end

    # Render to string the partial for each individual doc.
    # For placename searching, render catalog/map_placename_search partial,
    #  full geojson hash is passed to the partial for easier local customization
    # For coordinate searches (or features with only coordinate data),
    #  render catalog/map_coordinate_search partial
    def render_leaflet_popup_content(geojson_hash, hits=nil)
      if search_mode == 'placename' && geojson_hash[:properties][placename_property.to_sym]
        @controller.render_to_string partial: 'catalog/map_placename_search',
                                     locals: { geojson_hash: geojson_hash, hits: hits }
      else
        @controller.render_to_string partial: 'catalog/map_spatial_search',
                                     locals: { coordinates: geojson_hash[:bbox].presence || geojson_hash[:geometry][:coordinates],
                                               hits: hits }
      end
    end

  end

end
