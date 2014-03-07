require 'blacklight'
require 'leaflet-rails'
require 'leaflet-markercluster-rails'
require 'leaflet-sidebar-rails'


module Blacklight
  module Maps
    class Engine < Rails::Engine

      # Set some default configurations
      Blacklight::Configuration.default_values[:view].maps.lat_lng_field = "geoloc"
      Blacklight::Configuration.default_values[:view].maps.placename_field = "subject_geo_facet"
      
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