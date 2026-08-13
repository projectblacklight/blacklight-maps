# frozen_string_literal: true

require 'rails/generators'

module BlacklightMaps
  class Install < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc 'Install Blacklight-Maps'

    def verify_blacklight_installed
      return if IO.read('app/controllers/application_controller.rb').include?('include Blacklight::Controller')

      say_status('info', 'BLACKLIGHT NOT INSTALLED; GENERATING BLACKLIGHT', :blue)
      generate 'blacklight:install'
    end

    # Add the npm package whenever there is a package.json, regardless of JS delivery mode.
    # Importmap apps need it so the SCSS @import resolves via node_modules.
    # Jsbundling apps need it for both JS bundling and CSS.
    def add_npm_package
      return unless File.exist?('package.json')

      if ENV['CI'] || test_app?
        run "yarn add file:#{Blacklight::Maps::Engine.root}"
      else
        run "yarn add blacklight-maps@#{BlacklightMaps::VERSION}"
      end
    end

    def add_javascript
      if using_importmaps?
        # importmap pins are registered automatically by the engine initializer
      elsif using_jsbundling?
        # package already added in add_npm_package
      else
        say_status('warning', 'Could not detect importmap-rails or a package.json. Add BlacklightMaps JS manually.', :yellow)
        return
      end

      append_to_file 'app/javascript/application.js' do
        <<~JS

          import BlacklightMaps from "blacklight-maps"
          new BlacklightMaps().connect()
        JS
      end
      say_status('info', 'Added BlacklightMaps import to app/javascript/application.js', :green)
    end

    def add_stylesheet
      main_css = %w[
        app/assets/stylesheets/application.bootstrap.scss
        app/assets/stylesheets/application.scss
        app/assets/stylesheets/application.css
      ].find { |f| File.exist?(f) }

      return say_status('warning', 'Could not find main stylesheet. Add Leaflet CSS and blacklight-maps styles manually.', :yellow) unless main_css

      prepend_to_file(main_css, leaflet_url_imports) unless File.read(main_css).include?('leaflet.css')
      append_to_file(main_css) { blacklight_maps_import } unless File.read(main_css).include?('blacklight-maps')
    end

    def build_assets
      return unless File.exist?('package.json')

      run 'yarn build:css'
      run 'yarn build' if using_jsbundling?
    end

    def install_catalog_controller_mixin
      inject_into_file 'app/controllers/catalog_controller.rb',
                       after: /include Blacklight::Catalog.*$/ do
        "\n  include BlacklightMaps::Controller\n"
      end
    end

    def add_coordinates_facet_field
      inject_into_file 'app/controllers/catalog_controller.rb',
                       after: /configure_blacklight do \|config\|.*$/ do
        "\n" \
        "    config.add_facet_field :coordinates,\n" \
        "                           filter_class: BlacklightMaps::CoordinatesFilterField,\n" \
        "                           filter_query_builder: BlacklightMaps::SpatialFilterQuery,\n" \
        "                           item_presenter: BlacklightMaps::SpatialItemPresenter,\n" \
        "                           show: false,\n" \
        "                           include_in_request: false,\n" \
        "                           label: 'Spatial Search'\n"
      end
    end

    # TODO: inject Solr configuration (if needed)
    def inject_solr_configuration
      target_file = 'solr/conf/schema.xml'
      return unless File.exist?(target_file)

      inject_into_file target_file,
                       after: %r{<copyField source="title_tsim" dest="title_spell"/>} do
        "\n  <copyField source=\"coordinates_srpt\" dest=\"coordinates_ssim\" />\n"
      end
    end

    private

    def using_importmaps?
      defined?(Importmap) && File.exist?('config/importmap.rb')
    end

    def using_jsbundling?
      File.exist?('package.json') && !using_importmaps?
    end

    def leaflet_url_imports
      <<~CSS
        @import url("https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.css");
        @import url("https://cdn.jsdelivr.net/npm/leaflet.markercluster@1.5.3/dist/MarkerCluster.css");
        @import url("https://cdn.jsdelivr.net/npm/leaflet.markercluster@1.5.3/dist/MarkerCluster.Default.css");
      CSS
    end

    def blacklight_maps_import
      <<~CSS
        @import "blacklight-maps/app/assets/stylesheets/blacklight_maps/blacklight-maps";
      CSS
    end

    def test_app?
      Rails.application.class.name == 'Internal::Application' # rubocop:disable Style/ClassEqualityComparison
    end
  end
end
