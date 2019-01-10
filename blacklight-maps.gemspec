# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blacklight/maps/version'

Gem::Specification.new do |spec|
  spec.name          = "blacklight-maps"
  spec.version       = Blacklight::Maps::VERSION
  spec.authors       = ["Chris Beer", "Jack Reed", "Eben English"]
  spec.email         = ["cabeer@stanford.edu", "pjreed@stanford.edu", "eenglish@bpl.org"]
  spec.summary       = %q{Maps for Blacklight}
  spec.homepage      = "https://github.com/projectblacklight/blacklight-maps"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "< 6"
  spec.add_dependency "blacklight", ">= 6.1.0", "< 7.0.0"
  spec.add_dependency "bootstrap-sass", "~> 3.2"
  spec.add_dependency "leaflet-rails", "0.7.7"
  spec.add_dependency "leaflet-markercluster-rails"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails", "~> 3.0"
  spec.add_development_dependency "jettywrapper"
  spec.add_development_dependency "engine_cart", "~> 0.4.0"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "poltergeist", ">= 1.5.0"
end
