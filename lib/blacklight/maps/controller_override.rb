module BlacklightMaps
  module ControllerOverride
    extend ActiveSupport::Concern
    included do
      solr_search_params_logic << :add_spatial_search_to_solr
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
          solr_parameters[:d] = 0.5
        end
      end
    end

  end

end