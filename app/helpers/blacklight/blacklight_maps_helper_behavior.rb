module Blacklight::BlacklightMapsHelperBehavior

  # @param [String] id the html id
  # @param [Hash] tag_options options to put on the tag
  def blacklight_map_tag id, tag_options = {}, &block
    default_data = {
        maxzoom: blacklight_config.view.maps.maxzoom,
        tileurl: blacklight_config.view.maps.tileurl,
        mapattribution: blacklight_config.view.maps.mapattribution
    }

    options = {id: id, data: default_data}.deep_merge(tag_options)
    if block_given?
      content_tag(:div, options, &block)
    else
      tag(:div, options)
    end
  end

  # return the placename value to be used as a link
  def placename_value(geojson_hash)
    geojson_hash[:properties][blacklight_config.view.maps.placename_property.to_sym]
  end

  # create a link to a bbox spatial search
  def link_to_bbox_search bbox_coordinates
    coords_for_search = bbox_coordinates.map { |v| v.to_s }
    link_to(t('blacklight.maps.interactions.bbox_search'),
            catalog_index_path(spatial_search_type: "bbox",
                               coordinates: "[#{coords_for_search[1]},#{coords_for_search[0]} TO #{coords_for_search[3]},#{coords_for_search[2]}]",
                               view: default_document_index_view_type))
  end

  # create a link to a location name facet value
  def link_to_placename_field field_value, field, displayvalue = nil
    if params[:f] && params[:f][field] && params[:f][field].include?(field_value)
      new_params = params
    else
      new_params = add_facet_params(field, field_value)
    end
    new_params[:view] = default_document_index_view_type
    link_to(displayvalue.presence || field_value,
            catalog_index_path(new_params.except(:id, :spatial_search_type, :coordinates)))
  end

  # create a link to a spatial search for a set of point coordinates
  def link_to_point_search point_coordinates
    new_params = params.except(:controller, :action, :view, :id, :spatial_search_type, :coordinates)
    new_params[:spatial_search_type] = "point"
    new_params[:coordinates] = "#{point_coordinates[1]},#{point_coordinates[0]}"
    new_params[:view] = default_document_index_view_type
    link_to(t('blacklight.maps.interactions.point_search'), catalog_index_path(new_params))
  end

  # return the facet field containing geographic data
  def map_facet_field
    blacklight_config.view.maps.facet_mode == "coordinates" ?
        blacklight_config.view.maps.coordinates_facet_field :
        blacklight_config.view.maps.geojson_field
  end

  # return an array of Blacklight::SolrResponse::Facets::FacetItem items
  def map_facet_values
    if @response.aggregations[map_facet_field]
      @response.aggregations[map_facet_field].items
    else
      []
    end
  end

  # render the location name for the Leaflet popup
  # separate from BlacklightMapsHelperBehavior#placename_value so
  # location name display can be easily customized
  def render_placename_heading(geojson_hash)
    geojson_hash[:properties][blacklight_config.view.maps.placename_property.to_sym]
  end

  # render the map for #index and #map views
  def render_index_map
    render :partial => 'catalog/index_map',
           :locals => {:geojson_features => serialize_geojson(map_facet_values)}
  end

  # determine the type of spatial search to use based on coordinates (bbox or point)
  def render_spatial_search_link coordinates
    if coordinates.length == 4
      link_to_bbox_search(coordinates)
    else
      link_to_point_search(coordinates)
    end
  end

  # pass the document or facet values to BlacklightMaps::GeojsonExport
  def serialize_geojson(documents, options={})
    export = BlacklightMaps::GeojsonExport.new(controller,
                                               controller.action_name,
                                               documents,
                                               options)
    export.to_geojson
  end
end
