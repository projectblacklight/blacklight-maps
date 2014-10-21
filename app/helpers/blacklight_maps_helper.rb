module BlacklightMapsHelper
  # TODO move methods to BlacklightMaps::BlacklightMapsHelperBehavior # figure out why this doesn't work!

  # @param [String] id the html id
  # @param [Hash] tag_options options to put on the tag
  def blacklight_map_tag id, tag_options = {}, &block
    default_data = {
        maxzoom: blacklight_config.view.maps.maxzoom,
        tileurl: blacklight_config.view.maps.tileurl,
        type: blacklight_config.view.maps.type,
        mapattribution: blacklight_config.view.maps.mapattribution
    }

    options = {id: id, data: default_data}.deep_merge(tag_options)
    if block_given?
      content_tag(:div, options, &block)
    else
      tag(:div, options)
    end
  end

  def link_to_bbox_search bbox_coordinates
    coords_for_search = bbox_coordinates.map { |v| v.to_s }
    #CatalogController.solr_search_params_logic += [bbox_filter(solr_parameters,coords_for_search)]
    link_to(t('blacklight.maps.leaflet.bbox_search'),
            catalog_index_path(:q => "*:*"))
  end

  def bbox_filter solr_parameters, coords_for_search
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "subject_bounding_box_geospatial:[#{coords_for_search[0]},#{coords_for_search[1]} TO #{coords_for_search[2]},#{coords_for_search[3]}]"
  end

  def link_to_placename_facet field_value, field, displayvalue = nil
    link_to(displayvalue.presence || field_value,
            catalog_index_path(:f => {field => [field_value]}))
  end

  def link_to_point_search point_coordinates
    #CatalogController.solr_search_params_logic += [point_filter(solr_parameters,coords_for_search)]
    link_to(t('blacklight.maps.leaflet.point_search'),
            catalog_index_path(:q => "*:*", :fq => ["!geofilt sfield=#{blacklight_config.view.maps.coordinates_field}"]))
  end

  def point_filter solr_parameters, coords_for_search
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "!geofilt sfield=#{blacklight_config.view.maps.coordinates_field}"
    solr_parameters[:pt] = "#{coords_for_search[0]},#{coords_for_search[1]}"
    solr_parameters[:d] = 0.01
  end

  def render_coordinate_search_link coordinates
    if coordinates.length == 4
      link_to_bbox_search(coordinates)
    else
      link_to_point_search(coordinates)
    end
  end

  def serialize_geojson
    export = BlacklightMaps::GeojsonExport.new(controller,
                                               controller.action_name,
                                               @response.docs)
    export.to_geojson
  end

end
