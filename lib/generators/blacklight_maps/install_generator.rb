require 'rails/generators'

module BlacklightMaps
  class Install < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    desc "Install Blacklight-Maps"

    def assets
      copy_file "blacklight_maps.css.scss", "app/assets/stylesheets/blacklight_maps.css.scss"

      unless IO.read("app/assets/javascripts/application.js").include?('blacklight-maps')
        marker = IO.read("app/assets/javascripts/application.js").include?('turbolinks') ?
          '//= require turbolinks' : "//= require jquery_ujs"
        insert_into_file "app/assets/javascripts/application.js", :after => marker do
          %q{
//
// Required by Blacklight-Maps
//= require blacklight-maps}
        end
      end
    end
  end
end