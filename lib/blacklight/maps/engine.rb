# frozen_string_literal: true

require 'blacklight'

module Blacklight
  module Maps
    class Engine < Rails::Engine
      # Adds the gem's JS to the asset paths so Propshaft can serve it, and
      # registers config/importmap.rb with importmap-rails.
      initializer 'blacklight_maps.importmap', before: 'importmap' do |app|
        app.config.assets.paths << Engine.root.join('app/javascript')
        if app.config.respond_to?(:importmap)
          app.config.importmap.paths << Engine.root.join('config/importmap.rb')
          app.config.importmap.cache_sweepers << Engine.root.join('app/javascript')
        end
      end

      # Set some default configurations.
      # Uses default_configuration block so our defaults run after BL8 initializes :view.
      initializer 'blacklight-maps.default_config' do |_app|
        Blacklight::Configuration.default_configuration do
          maps = Blacklight::Configuration.default_values[:view].maps
          maps.geojson_field = 'geojson_ssim'
          maps.placename_property = 'placename'
          maps.coordinates_field = 'coordinates_srpt'
          maps.search_mode = 'placename' # or 'coordinates'
          maps.spatial_query_dist = 0.5
          maps.placename_field = 'subject_geo_ssim'
          maps.coordinates_facet_field = 'coordinates_ssim'
          maps.facet_mode = 'geojson' # or 'coordinates'
          maps.tileurl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
          maps.mapattribution = 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
          maps.maxzoom = 18
          maps.show_initial_zoom = 5
        end
      end

      # Add our helpers
      initializer 'blacklight-maps.helpers' do |_app|
        config.after_initialize do
          ActionView::Base.include BlacklightMapsHelper
        end
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
