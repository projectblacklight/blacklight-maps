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
    link_to(t('blacklight.maps.leaflet.bbox_search'),
            catalog_index_path(spatial_search_type: "bbox",
                               coordinates: "[#{coords_for_search[1]},#{coords_for_search[0]} TO #{coords_for_search[3]},#{coords_for_search[2]}]"))
  end

  def link_to_placename_facet field_value, field, displayvalue = nil
    link_to(displayvalue.presence || field_value,
            catalog_index_path(:f => {field => [field_value]}))
  end

  def link_to_point_search point_coordinates
    link_to(t('blacklight.maps.leaflet.point_search'),
            catalog_index_path(spatial_search_type:"point",
                               coordinates:"#{point_coordinates[1]},#{point_coordinates[0]}"))
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
