require "blacklight/maps/version"

module Blacklight
  module Maps
    require 'blacklight/maps/controller_override'
    require 'blacklight/maps/engine'
    require 'blacklight/maps/export'
    require 'blacklight/maps/geometry'

    def self.inject!
      CatalogController.send(:include, BlacklightMaps::ControllerOverride)
      RenderConstraintsHelper.send(:include, BlacklightMaps::RenderConstraintsOverride)
    end

  end
end
