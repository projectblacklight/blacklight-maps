# frozen_string_literal: true

module BlacklightMaps
  # FilterField for spatial coordinate searches (bounding box and point).
  class CoordinatesFilterField < Blacklight::SearchState::FilterField
    SpatialConstraintValue = Struct.new(:value, :label)

    def initialize(*args)
      super
      @filters_key = :coordinates
    end

    # @return [Array] the active spatial constraint as a single-element array, or empty
    def values(except: [])
      return [] if except.include?(:filters) || search_state.params[:coordinates].blank?

      label = if search_state.params[:spatial_search_type] == 'bbox'
                I18n.t('blacklight.search.filters.coordinates.bbox')
              else
                I18n.t('blacklight.search.filters.coordinates.point')
              end

      [SpatialConstraintValue.new(search_state.params[:coordinates], label)]
    end

    # Remove both spatial params from the search state
    # @return [Blacklight::SearchState]
    def remove(_item)
      new_state = search_state.reset_search
      new_state.params.delete(:coordinates)
      new_state.params.delete(:spatial_search_type)
      new_state
    end

    delegate :include?, to: :values

    # Permit both spatial params
    def permitted_params
      %i[coordinates spatial_search_type]
    end
  end
end
