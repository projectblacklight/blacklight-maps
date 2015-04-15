module BlacklightMaps
  module ControllerOverride
    extend ActiveSupport::Concern
    included do

      if self.respond_to? :search_params_logic
        search_params_logic << :add_spatial_search_to_solr
      end

      if self.blacklight_config.search_builder_class
        self.blacklight_config.search_builder_class.send(:include,
                                                         BlacklightMaps::MapsSearchBuilder
        ) unless
            self.blacklight_config.search_builder_class.include?(
                BlacklightMaps::MapsSearchBuilder
            )
      end

    end

    def map
      (@response, @document_list) = search_results(params, search_params_logic)
      params[:view] = 'maps'
      respond_to do |format|
        format.html
      end
    end

  end

end