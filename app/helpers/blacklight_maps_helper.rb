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

  def link_to_geo_facet(field_value, field, displayvalue = nil)
    new_params = {}
    new_params[:action] = 'index'
    new_params[:controller] = 'catalog'
    new_params[:f] = {field => [field_value]}
    link_to(displayvalue.presence || field_value, new_params)
  end

  def serialize_geojson
    export = BlacklightMaps::GeojsonExport.new(controller,
                                               controller.action_name,
                                               @response.docs)
    export.to_geojson
  end

end
