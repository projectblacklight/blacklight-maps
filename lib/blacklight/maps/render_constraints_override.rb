# Meant to be applied on top of Blacklight view helpers, to over-ride
# certain methods from RenderConstraintsHelper (newish in BL),
# to affect constraints rendering
module BlacklightMaps

  module RenderConstraintsOverride

    # BlacklightMaps override: check for coordinate parameters
    ##
    # Check if the query has any constraints defined (a query, facet, coordinate, etc)
    #
    # @param [Hash] query parameters
    # @return [Boolean]
    def query_has_constraints?(localized_params = params)
      !(localized_params[:q].blank? and localized_params[:f].blank? and localized_params[:coordinates].blank?)
    end

    # BlacklightMaps override: include render_coordinate_query() in rendered constraints
    ##
    # Render the actual constraints, not including header or footer
    # info.
    #
    # @param [Hash] query parameters
    # @return [String]
    def render_constraints(localized_params = params)
      render_spatial_query(localized_params) + render_constraints_query(localized_params) + render_constraints_filters(localized_params)
    end

    # BlacklightMaps override: include render_search_to_s_coord() in rendered constraints
    # Simpler textual version of constraints, used on Search History page.
    def render_search_to_s(params)
      render_search_to_s_coord(params) +
      render_search_to_s_q(params) +
      render_search_to_s_filters(params)
    end

    ##
    # Render the search query constraint
    def render_search_to_s_coord(params)
      return "".html_safe if params[:coordinates].blank?
      render_search_to_s_element(spatial_constraint_label(params) , render_filter_value(params[:coordinates]) )
    end

    ##
    # Render the spatial query constraints
    #
    # @param [Hash] query parameters
    # @return [String]
    def render_spatial_query(localized_params = params)
      # So simple don't need a view template, we can just do it here.
      scope = localized_params.delete(:route_set) || self
      return ''.html_safe if localized_params[:coordinates].blank?

      render_constraint_element(spatial_constraint_label(localized_params),
                                localized_params[:coordinates],
                                :classes => ['coordinates'],
                                :remove => scope.url_for(localized_params.merge(:coordinates=>nil,
                                                                                :spatial_search_type=>nil,
                                                                                :action=>'index')))
    end

    def spatial_constraint_label(params)
      (params[:spatial_search_type] && params[:spatial_search_type] == 'bbox') ?
          t('blacklight.search.filters.coordinates.bbox') :
          t('blacklight.search.filters.coordinates.point')
    end

  end

end