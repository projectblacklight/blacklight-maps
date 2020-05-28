# frozen_string_literal: true

# Meant to be applied on top of Blacklight view helpers, to over-ride
# certain methods from RenderConstraintsHelper (newish in BL),
# to affect constraints rendering
module BlacklightMaps
  module RenderConstraintsOverride
    # @param search_state [Blacklight::SearchState]
    # @return [Boolean]
    def has_spatial_parameters?(search_state)
      search_state.params[:coordinates].present?
    end

    # BlacklightMaps override: check for coordinate parameters
    # @param params_or_search_state [Blacklight::SearchState || ActionController::Parameters]
    # @return [Boolean]
    def query_has_constraints?(params_or_search_state = search_state)
      search_state = convert_to_search_state(params_or_search_state)
      has_spatial_parameters?(search_state) || super
    end

    # BlacklightMaps override: include render_spatial_query() in rendered constraints
    # @param localized_params [Hash] localized_params query parameters
    # @param local_search_state [Blacklight::SearchState]
    # @return [String]
    def render_constraints(localized_params = params, local_search_state = search_state)
      params_or_search_state = if localized_params != params
                                 localized_params
                               else
                                 local_search_state
                               end
      render_spatial_query(params_or_search_state) + super
    end

    # BlacklightMaps override: include render_search_to_s_coord() in rendered constraints
    # Simpler textual version of constraints, used on Search History page.
    # @param params [Hash]
    # @return [String]
    def render_search_to_s(params)
      render_search_to_s_coord(params) + super
    end

    ##
    # Render the search query constraint
    # @param params [Hash]
    # @return [String]
    def render_search_to_s_coord(params)
      return ''.html_safe if params[:coordinates].blank?

      render_search_to_s_element(spatial_constraint_label(params),
                                 render_filter_value(params[:coordinates]))
    end

    # Render the spatial query constraints
    # @param params_or_search_state [Blacklight::SearchState || ActionController::Parameters]
    # @return [String]
    def render_spatial_query(params_or_search_state = search_state)
      search_state = convert_to_search_state(params_or_search_state)

      # So simple don't need a view template, we can just do it here.
      return ''.html_safe if search_state.params[:coordinates].blank?

      render_constraint_element(spatial_constraint_label(search_state),
                                search_state.params[:coordinates],
                                classes: ['coordinates'],
                                remove: remove_spatial_params(search_state)) # _params.except!(:coordinates, :spatial_search_type)
    end

    ##
    #
    # @param search_state [Blacklight::SearchState]
    # @return [String]
    # remove the spatial params from params
    def remove_spatial_params(search_state)
      search_action_path(search_state.params.dup.except!(:coordinates, :spatial_search_type))
    end

    ##
    # render the label for the spatial constraint
    # @param params_or_search_state [Blacklight::SearchState || ActionController::Parameters]
    # @return [String]
    def spatial_constraint_label(params_or_search_state)
      search_params = if params_or_search_state.is_a?(Blacklight::SearchState)
                        params_or_search_state.params
                      else
                        params_or_search_state
                      end
      if search_params[:spatial_search_type] && search_params[:spatial_search_type] == 'bbox'
        t('blacklight.search.filters.coordinates.bbox')
      else
        t('blacklight.search.filters.coordinates.point')
      end
    end
  end
end
