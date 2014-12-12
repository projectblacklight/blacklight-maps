require 'blacklight'
require 'leaflet-rails'
require 'leaflet-markercluster-rails'

module Blacklight
  module Maps
    class Engine < Rails::Engine
      # Set some default configurations
      Blacklight::Configuration.default_values[:view].maps.geojson_field = "geojson"
      Blacklight::Configuration.default_values[:view].maps.placename_property = "placename"
      Blacklight::Configuration.default_values[:view].maps.coordinates_field = "coordinates"
      Blacklight::Configuration.default_values[:view].maps.search_mode = "placename_facet" # or 'coordinates'
      Blacklight::Configuration.default_values[:view].maps.placename_facet_field = "placename_facet_field"
      Blacklight::Configuration.default_values[:view].maps.coordinates_facet_field = "coordinates_facet_field"
      Blacklight::Configuration.default_values[:view].maps.facet_mode = "coordinates" # or 'geojson'
      Blacklight::Configuration.default_values[:view].maps.tileurl = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      Blacklight::Configuration.default_values[:view].maps.mapattribution = 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
      Blacklight::Configuration.default_values[:view].maps.maxzoom = 18
      Blacklight::Configuration.default_values[:view].maps.show_initial_zoom = 5

      # Add our helpers
      initializer 'blacklight-maps.helpers' do |app|
        ActionView::Base.send :include, BlacklightMapsHelper
      end

      config.to_prepare do
        Blacklight::Maps.inject!
      end

      # This makes our rake tasks visible.
      rake_tasks do
        Dir.chdir(File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))) do
          Dir.glob(File.join('railties', '*.rake')).each do |railtie|
            load railtie
          end
        end
      end
    end
  end
end
