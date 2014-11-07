# Meant to be applied on top of Blacklight view helpers, to over-ride
# certain methods from RenderConstraintsHelper (newish in BL),
# to affect constraints rendering
module BlacklightMaps

  module RenderConstraintsOverride
    extend ActiveSupport::Concern

    ##
    # Check if the query has any constraints defined (a query, facet, coordinate, etc)
    #
    # @param [Hash] query parameters
    # @return [Boolean]
    def query_has_constraints?(localized_params = params)
      !(localized_params[:q].blank? and localized_params[:f].blank? and localized_params[:coordinates].blank?)
    end

  end

end