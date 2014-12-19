module BlacklightMaps
  module ControllerOverride
    extend ActiveSupport::Concern
    included do
      solr_search_params_logic << :add_spatial_search_to_solr
    end

    def map
      (@response, @document_list) = get_search_results
      params[:view] = 'maps'
      respond_to do |format|
        format.html
      end
    end

    # add spatial search params to solr
    def add_spatial_search_to_solr(solr_parameters, user_parameters)
      if user_parameters[:spatial_search_type] && user_parameters[:coordinates]
        solr_parameters[:fq] ||= []
        if user_parameters[:spatial_search_type] == 'bbox'
          solr_parameters[:fq] << blacklight_config.view.maps.coordinates_field + ":" + user_parameters[:coordinates]
        else
          solr_parameters[:fq] << "{!geofilt sfield=#{blacklight_config.view.maps.coordinates_field}}"
          solr_parameters[:pt] = user_parameters[:coordinates]
          solr_parameters[:d] = blacklight_config.view.maps.spatial_query_dist
        end
      end
      solr_parameters
    end

  end

end