# frozen_string_literal: true

module BlacklightMaps
  # Builds the appropriate solr spatial filter query from the active
  # coordinates and spatial_search_type params.
  class SpatialFilterQuery
    def self.call(search_builder, filter, _solr_parameters)
      search_state = filter.search_state
      coordinates = search_state.params[:coordinates]
      spatial_search_type = search_state.params[:spatial_search_type]
      maps_config = search_builder.blacklight_config.view.maps

      return [nil, nil] if coordinates.blank?

      if spatial_search_type == 'bbox'
        ["#{maps_config.coordinates_field}:#{coordinates}", nil]
      else
        ["{!geofilt sfield=#{maps_config.coordinates_field}}", { pt: coordinates, d: maps_config.spatial_query_dist }]
      end
    end
  end
end
