require "blacklight/maps/version"

module Blacklight
  module Maps
    require 'blacklight/maps/controller_override'
    require 'blacklight/maps/render_constraints_override'
    require 'blacklight/maps/engine'
    require 'blacklight/maps/export'
    require 'blacklight/maps/geometry'

    def self.inject!
      CatalogController.send(:include, BlacklightMaps::ControllerOverride)
      CatalogController.send(:include, BlacklightMaps::RenderConstraintsOverride)
      CatalogController.send(:helper, BlacklightMaps::RenderConstraintsOverride) unless
          CatalogController.helpers.is_a?(BlacklightMaps::RenderConstraintsOverride)

      # inject into SearchHistory and SavedSearches so spatial queries display properly
      SearchHistoryController.send(:helper, BlacklightMaps::RenderConstraintsOverride) unless
          SearchHistoryController.helpers.is_a?(BlacklightMaps::RenderConstraintsOverride)
      SavedSearchesController.send(:helper, BlacklightMaps::RenderConstraintsOverride) unless
          SavedSearchesController.helpers.is_a?(BlacklightMaps::RenderConstraintsOverride)
    end

  end
end
