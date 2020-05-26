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
    def initialize(controller, action, response_docs, options = {})
      @controller = controller
      @action = action
      @response_docs = response_docs
      @options = options
      @features = []
    end

    # build the GeoJSON FeatureCollection
    def to_geojson
      { type: 'FeatureCollection', features: build_geojson_features }.to_json
    end

    private

    def maps_config
      @controller.blacklight_config.view.maps
    end

    def geojson_field
      maps_config.geojson_field
    end

    def coordinates_field
      maps_config.coordinates_field
    end

    # build GeoJSON features array
    # determine how to build GeoJSON feature based on config and controller#action
    def build_geojson_features
      if @action == :index || @action == :map
        build_index_features
      elsif @action == :show
        build_show_features
      end
      @features
    end

    # build GeoJSON features array for index and map views
    def build_index_features
      @response_docs.each do |geofacet|
        @features << if maps_config.facet_mode == 'coordinates'
                       build_feature_from_coords(geofacet.value, geofacet.hits)
                     else
                       build_feature_from_geojson(geofacet.value, geofacet.hits)
                     end
      end
    end

    # build GeoJSON features array for show view
    def build_show_features
      doc = @response_docs
      return unless doc[geojson_field] || doc[coordinates_field]

      if doc[geojson_field]
        build_features_from_geojson(doc[geojson_field])
      elsif doc[coordinates_field]
        build_features_from_coords(doc[coordinates_field])
      end
    end

    def build_features_from_geojson(geojson_field_values)
      return unless geojson_field_values

      geojson_field_values.uniq.each do |loc|
        @features << build_feature_from_geojson(loc)
      end
    end

    def build_features_from_coords(coordinates_field_values)
      return unless coordinates_field_values

      coordinates_field_values.uniq.each do |coords|
        @features << build_feature_from_coords(coords)
      end
    end

    # build blacklight-maps GeoJSON feature from GeoJSON-formatted data
    # turn bboxes into points for index view so we don't get weird mix of boxes and markers
    def build_feature_from_geojson(loc, hits = nil)
      geojson = JSON.parse(loc).deep_symbolize_keys
      if @action != :show && geojson[:bbox]
        bbox = Geometry::BoundingBox.new(geojson[:bbox])
        geojson[:geometry][:coordinates] = Geometry::Point.new(bbox.find_center).normalize_for_search
        geojson[:geometry][:type] = 'Point'
        geojson.delete(:bbox)
      end
      geojson[:properties] ||= {}
      geojson[:properties][:hits] = hits.to_i if hits
      geojson[:properties][:popup] = render_leaflet_popup_content(geojson, hits)
      geojson
    end

    # build blacklight-maps GeoJSON feature from coordinate data
    # turn bboxes into points for index view so we don't get weird mix of boxes and markers
    def build_feature_from_coords(coords, hits = nil)
      geojson = { type: 'Feature', properties: {} }
      if coords =~ /ENVELOPE/ # bbox
        geojson.merge!(build_bbox_feature_from_coords(coords))
      elsif coords.match(/^[-]?[\d]*[\.]?[\d]*[ ,][-]?[\d]*[\.]?[\d]*$/) # point
        geojson[:geometry] = build_point_geometry(coords)
      else
        Rails.logger.error("This coordinate format is not yet supported: '#{coords}'")
      end
      geojson[:properties] = { popup: render_leaflet_popup_content(geojson, hits) } if geojson[:geometry][:coordinates]
      geojson[:properties][:hits] = hits.to_i if hits
      geojson
    end

    def build_bbox_feature_from_coords(coords)
      geojson = { geometry: {} }
      bbox = Geometry::BoundingBox.from_wkt_envelope(coords)
      if @action != :show
        geojson[:geometry][:type] = 'Point'
        geojson[:geometry][:coordinates] = Geometry::Point.new(bbox.find_center).normalize_for_search
      else
        coords_array = bbox.to_a
        geojson[:bbox] = coords_array
        geojson[:geometry][:type] = 'Polygon'
        geojson[:geometry][:coordinates] = bbox.geojson_geometry_array
      end
      geojson
    end

    def build_point_geometry(coords)
      geometry = { type: 'Point' }
      coords_array = coords.match(/,/) ? coords.split(',').reverse : coords.split(' ')
      geometry[:coordinates] = coords_array.map(&:to_f)
      geometry
    end

    # Render to string the partial for each individual doc.
    # For placename searching, render catalog/map_placename_search partial,
    #  pass the full geojson hash to the partial for easier local customization
    # For coordinate searches (or features with only coordinate data),
    #  render catalog/map_coordinate_search partial
    def render_leaflet_popup_content(geojson, hits = nil)
      if maps_config.search_mode == 'placename' &&
                                     geojson[:properties][maps_config.placename_property.to_sym]
        @controller.render_to_string(partial: 'catalog/map_placename_search',
                                     locals: { geojson_hash: geojson, hits: hits })
      else
        @controller.render_to_string(partial: 'catalog/map_spatial_search',
                                     locals: { coordinates: geojson[:bbox].presence || geojson[:geometry][:coordinates],
                                               hits: hits })
      end
    end
  end
end
