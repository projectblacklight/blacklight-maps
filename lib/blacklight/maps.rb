# frozen_string_literal: true

require 'blacklight/maps/version'

module Blacklight
  module Maps
    require 'blacklight/maps/controller'
    require 'blacklight/maps/engine'
    require 'blacklight/maps/export'
    require 'blacklight/maps/geometry'

    # returns the full path to the blacklight plugin installation
    def self.root
      @root ||= File.expand_path(File.dirname(File.dirname(File.dirname(__FILE__))))
    end
  end
end
