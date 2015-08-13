module BlacklightMaps
  module MapsSearchBuilder

    # add spatial search params to solr
    def add_spatial_search_to_solr(solr_parameters = {})
      if blacklight_params[:spatial_search_type] && blacklight_params[:coordinates]
        solr_parameters[:fq] ||= []
        if blacklight_params[:spatial_search_type] == 'bbox'
          solr_parameters[:fq] << blacklight_config.view.maps.coordinates_field + ":" + blacklight_params[:coordinates]
        else
          solr_parameters[:fq] << "{!geofilt sfield=#{blacklight_config.view.maps.coordinates_field}}"
          solr_parameters[:pt] = blacklight_params[:coordinates]
          solr_parameters[:d] = blacklight_config.view.maps.spatial_query_dist
        end
      end
      solr_parameters
    end

  end
end