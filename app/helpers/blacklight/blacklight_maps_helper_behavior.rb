# frozen_string_literal: true

module Blacklight
  module BlacklightMapsHelperBehavior
    # @param id [String] the html element id
    # @param tag_options [Hash] options to put on the tag
    def blacklight_map_tag(id, tag_options = {}, &block)
      maps_config = blacklight_config.view.maps
      default_data = {
        maxzoom: maps_config.maxzoom,
        tileurl: maps_config.tileurl,
        mapattribution: maps_config.mapattribution
      }
      options = { id: id, data: default_data }.deep_merge(tag_options)
      block_given? ? content_tag(:div, options, &block) : tag(:div, options)
    end

    # return the placename value to be used as a link
    # @param geojson_hash [Hash]
    def placename_value(geojson_hash)
      geojson_hash[:properties][blacklight_config.view.maps.placename_property.to_sym]
    end

    # create a link to a bbox spatial search
    # @param bbox [Array]
    def link_to_bbox_search(bbox)
      bbox_coords = bbox.map(&:to_s)
      bbox_search_coords = "[#{bbox_coords[1]},#{bbox_coords[0]} TO #{bbox_coords[3]},#{bbox_coords[2]}]"
      link_to(t('blacklight.maps.interactions.bbox_search'),
              search_catalog_path(spatial_search_type: 'bbox',
                                  coordinates: bbox_search_coords,
                                  view: default_document_index_view_type))
    end

    # create a link to a location name facet value
    # @param field_value [String] Solr field value
    # @param field [String] Solr field name
    # @param display_value [String] value to display instead of field_value
    def link_to_placename_field(field_value, field, display_value = nil)
      new_params = if params[:f] && params[:f][field]&.include?(field_value)
                     search_state.params
                   else
                     search_state.add_facet_params(field, field_value)
                   end
      new_params[:view] = default_document_index_view_type
      new_params.except!(:id, :spatial_search_type, :coordinates, :controller, :action)
      link_to(display_value.presence || field_value, search_catalog_path(new_params))
    end

    # create a link to a spatial search for a set of point coordinates
    # @param point_coords [Array]
    def link_to_point_search(point_coords)
      new_params = params.except(:controller, :action, :view, :id, :spatial_search_type, :coordinates)
      new_params[:spatial_search_type] = 'point'
      new_params[:coordinates] = "#{point_coords[1]},#{point_coords[0]}"
      new_params[:view] = default_document_index_view_type
      new_params.permit!
      link_to(t('blacklight.maps.interactions.point_search'), search_catalog_path(new_params))
    end

    # render the location name for the Leaflet popup
    # @param geojson_hash [Hash]
    def render_placename_heading(geojson_hash)
      geojson_hash[:properties][blacklight_config.view.maps.placename_property.to_sym]
    end

    # render the map for #index and #map views
    def render_index_mapview
      maps_config = blacklight_config.view.maps
      map_facet_field = if maps_config.facet_mode == 'coordinates'
                          maps_config.coordinates_facet_field
                        else
                          maps_config.geojson_field
                        end
      map_facet_values = @response.aggregations[map_facet_field]&.items || []
      render partial: 'catalog/index_mapview',
             locals: { geojson_features: serialize_geojson(map_facet_values) }
    end

    # determine the type of spatial search to use based on coordinates (bbox or point)
    # @param coords [Array]
    def render_spatial_search_link(coords)
      coords.length == 4 ? link_to_bbox_search(coords) : link_to_point_search(coords)
    end

    # pass the document or facet values to BlacklightMaps::GeojsonExport
    # @param documents [Array || SolrDocument]
    def serialize_geojson(documents, options = {})
      export = BlacklightMaps::GeojsonExport.new(controller,
                                                 action_name.to_sym,
                                                 documents,
                                                 options)
      export.to_geojson
    end
  end
end
