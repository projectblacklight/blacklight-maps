# frozen_string_literal: true

require 'rails/generators'

module BlacklightMaps
  class Install < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    desc 'Install Blacklight-Maps'
    # TODO: how to add assets
    def assets
      copy_file "blacklight_maps.css.scss", "app/assets/stylesheets/blacklight_maps.css.scss"

      unless IO.read("app/assets/javascripts/application.js").include?('blacklight-maps')
        marker = "//= require blacklight/blacklight"
        insert_into_file "app/assets/javascripts/application.js", after: marker do
          %q{
//
// Required by Blacklight-Maps
//= require blacklight-maps}
        end
      end
    end

    def inject_search_builder
      inject_into_file 'app/models/search_builder.rb',
                       after: /include Blacklight::Solr::SearchBuilderBehavior.*$/ do
        "\n  include BlacklightMaps::MapsSearchBuilderBehavior\n"
      end
    end

    def install_catalog_controller_mixin
      inject_into_file 'app/controllers/catalog_controller.rb',
                       after: /include Blacklight::Catalog.*$/ do
        "\n  include BlacklightMaps::Controller\n"
      end
    end

    def install_search_history_controller
      target_file = 'app/controllers/search_history_controller.rb'
      if File.exists?(target_file)
        inject_into_file target_file,
                         after: /include Blacklight::SearchHistory/ do
          "\n  helper BlacklightMaps::RenderConstraintsOverride\n"
        end
      else
        copy_file 'search_history_controller.rb', target_file
      end
    end

    # TODO: inject Solr configuration (if needed)
    def inject_solr_configuration
      target_file = 'solr/conf/schema.xml'
      return unless File.exists?(target_file)
      inject_into_file target_file,
                       after: %r{<copyField source="title_tsim" dest="title_spell"/>} do
        "\n  <copyField source=\"coordinates_srpt\" dest=\"coordinates_ssim\" />\n"
      end
    end
  end
end
