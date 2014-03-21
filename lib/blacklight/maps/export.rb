module BlacklightMaps

  # This class provides the ability to export a response document to GeoJSON.
  # The export is formated as a GeoJSON FeatureCollection, where the features
  # consist of an array of Point features.  For more on the GeoJSON
  # specification see http://geojson.org/geojson-spec.html.
  #
  class GeojsonExport
    include BlacklightMaps

    # controller is a Blacklight CatalogController object passed by a helper
    # response_docs is an array of documents passed by a helper
    def initialize(controller, response_docs)
      @controller = controller
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

    def type
      blacklight_maps_config.type
    end

    def placename_coord_field
      blacklight_maps_config.placename_coord_field
    end

    def placename_coord_delimiter
      blacklight_maps_config.placename_coord_delimiter
    end

    def bbox_field
      blacklight_maps_config.bbox_field
    end

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

    # Render to string the partial for each individual doc
    def render_leaflet_sidebar_partial(doc)
      @controller.render_to_string partial: 'catalog/index_maps',
                                   locals: { document: SolrDocument.new(doc) }
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
  end
end
