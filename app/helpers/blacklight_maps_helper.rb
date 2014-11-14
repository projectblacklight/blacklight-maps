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

  # return the facet field containing geographic data
  def map_facet_field
    blacklight_config.view.maps.facet_mode == "coordinates" ?
        blacklight_config.view.maps.coordinates_facet_field :
        blacklight_config.view.maps.geojson_field
  end

  # return an array of Blacklight::SolrResponse::Facets::FacetItem items
  def map_facet_values
    if @response.facet_by_field_name(map_facet_field)
      @response.facet_by_field_name(map_facet_field).items
    else
      []
    end
  end

  def render_coordinate_search_link coordinates
    if coordinates.length == 4
      link_to_bbox_search(coordinates)
    else
      link_to_point_search(coordinates)
    end
  end

  def render_index_map
    render :partial => 'catalog/index_map',
           :locals => {:geojson_features => serialize_geojson(map_facet_values)}
  end

  def serialize_geojson(documents)
    export = BlacklightMaps::GeojsonExport.new(controller,
                                               controller.action_name,
                                               documents)
    export.to_geojson
  end

  # determine the best viewpoint for the map
  def set_viewpoint(geojson_features)
    geojson_docs = JSON.parse(geojson_features)["features"]
    if geojson_docs.length == 1
      viewpoint = geojson_docs[0]["bbox"] ?
          BlacklightMaps::Geometry::BoundingBox.new(geojson_docs[0]["bbox"]).find_center.reverse :
          geojson_docs[0]["geometry"]["coordinates"].reverse
    elsif geojson_docs.length > 1
      longs, lats = [[],[]]
      geojson_docs.each do |feature|
        if feature["bbox"]
          feature["bbox"].values_at(0,2).each {|long| longs << long }
          feature["bbox"].values_at(1,3).each {|lat| lats << lat }
        else
          longs << feature["geometry"]["coordinates"][0]
          lats << feature["geometry"]["coordinates"][1]
        end
      end
      sorted_longs, sorted_lats = longs.sort, lats.sort
      viewpoint = [[sorted_lats.first,sorted_longs.first],[sorted_lats.last,sorted_longs.last]]
    else
      viewpoint = [0,0]
    end
    viewpoint
  end

end
