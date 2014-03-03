require 'blacklight'

module Blacklight
  module Maps
    class Engine < Rails::Engine
      Blacklight::Configuration.default_values[:view].maps.lat_lng_field = "zzz_pt"

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