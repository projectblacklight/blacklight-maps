# frozen_string_literal: true

module BlacklightMaps
  module Controller
    extend ActiveSupport::Concern

    included do
      helper BlacklightMaps::RenderConstraintsOverride
    end

    def map
      (@response, @document_list) = search_service.search_results
      params[:view] = 'maps'
      respond_to do |format|
        format.html
      end
    end

    ##
    # BlacklightMaps override: update to look for spatial query params
    # Check if any search parameters have been set
    # @return [Boolean]
    def has_search_parameters?
      params[:coordinates].present? || super
    end
  end
end
