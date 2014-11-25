# Meant to be applied on top of Blacklight view helpers, to over-ride
# certain methods from RenderConstraintsHelper (newish in BL),
# to affect constraints rendering
module BlacklightMaps

  module RenderConstraintsOverride

    # BlacklightMaps override: update to look for spatial query params
    def has_search_parameters?
      has_spatial_parameters? || super
    end

    def has_spatial_parameters?
      !params[:coordinates].blank?
    end

    # BlacklightMaps override: check for coordinate parameters
    def query_has_constraints?(localized_params = params)
      has_search_parameters? || super
    end

    # BlacklightMaps override: include render_spatial_query() in rendered constraints
    def render_constraints(localized_params = params)
      render_spatial_query(localized_params) + super
    end

    # BlacklightMaps override: include render_search_to_s_coord() in rendered constraints
    # Simpler textual version of constraints, used on Search History page.
    def render_search_to_s(params)
      render_search_to_s_coord(params) + super
    end

    ##
    # Render the search query constraint
    def render_search_to_s_coord(params)
      return "".html_safe if params[:coordinates].blank?
      render_search_to_s_element(spatial_constraint_label(params) , render_filter_value(params[:coordinates]) )
    end

    # Render the spatial query constraints
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