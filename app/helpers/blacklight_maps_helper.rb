# Helper methods used for Blacklight Maps
module BlacklightMapsHelper
  # @param [String] id the html id
  # @param [Hash] tag_options options to put on the tag
  def blacklight_map_tag id, tag_options = {}, &block
    default_data = {
      maxzoom: blacklight_config.view.maps.maxzoom,
      tileurl: blacklight_config.view.maps.tileurl,
      type: blacklight_config.view.maps.type
    }

    options = {id: id, data: default_data}.deep_merge(tag_options)
    if block_given?
      content_tag(:div, options, &block)
    else
      tag(:div, options)
    end
  end

  def serialize_geojson
    export = BlacklightMaps::GeojsonExport.new(controller,
                                               @response.docs)
    export.to_geojson
  end
end
