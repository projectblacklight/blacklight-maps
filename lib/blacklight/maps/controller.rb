# frozen_string_literal: true

module BlacklightMaps
  module Controller
    extend ActiveSupport::Concern

    included do
      send(:include, BlacklightMaps::RenderConstraintsOverride)
      send(:helper, BlacklightMaps::RenderConstraintsOverride)
    end

    def map
      (@response, @document_list) = search_service.search_results
      params[:view] = 'maps'
      respond_to do |format|
        format.html
      end
    end
  end
end
