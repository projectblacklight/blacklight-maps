require 'rails/generators'

module BlacklightMaps
  class Install < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    def assets
      copy_file "blacklight_maps.css.scss", "app/assets/stylesheets/blacklight_maps.css.scss"
    end
  end
end