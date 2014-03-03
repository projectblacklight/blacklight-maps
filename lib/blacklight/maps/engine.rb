require 'blacklight'

module Blacklight
  module Maps
    class Engine < Rails::Engine
      Blacklight::Configuration.default_values[:view].maps.lat_lng_field = "zzz_pt"
    end
  end
end