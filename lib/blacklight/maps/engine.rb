require 'blacklight'
require 'leaflet-rails'
require 'leaflet-markercluster-rails'
require 'leaflet-sidebar-rails'

module Blacklight
  module Maps
    class Engine < Rails::Engine
      # Set some default configurations
      Blacklight::Configuration.default_values[:view].maps.type = 'bbox'
      Blacklight::Configuration.default_values[:view].maps.bbox_field = 'place_bbox'
      Blacklight::Configuration.default_values[:view].maps.placename_coord_field = 'placename_coords'
      Blacklight::Configuration.default_values[:view].maps.tileurl = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      Blacklight::Configuration.default_values[:view].maps.mapattribution = 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
      Blacklight::Configuration.default_values[:view].maps.maxzoom = 8
      Blacklight::Configuration.default_values[:view].maps.placename_coord_delimiter = '-|-'

      # Add our helpers
      initializer 'blacklight-maps.helpers' do |app|
        ActionView::Base.send :include, BlacklightMapsHelper
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
