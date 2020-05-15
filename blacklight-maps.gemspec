# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blacklight/maps/version'

Gem::Specification.new do |s|
  s.name          = 'blacklight-maps'
  s.version       = Blacklight::Maps::VERSION
  s.authors       = ['Chris Beer', 'Jack Reed', 'Eben English']
  s.email         = %w[cabeer@stanford.edu pjreed@stanford.edu eenglish@bpl.org]
  s.summary       = 'Maps for Blacklight'
  s.description   = 'Blacklight plugin providing map views for records with geographic data.'
  s.homepage      = 'https://github.com/projectblacklight/blacklight-maps'
  s.license       = 'Apache-2.0'

  s.files         = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'blacklight', '~> 7.0'
  s.add_dependency 'rails', '>= 5.1', '< 7'
  # TODO: figure out JS
  s.add_dependency 'leaflet-rails', '~> 1.0'
  # s.add_dependency 'leaflet-markercluster-rails'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'engine_cart', '~> 2.1'
  s.add_development_dependency 'poltergeist', '>= 1.5.0'
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'rubocop', '~> 0.63.0'
  s.add_development_dependency 'rubocop-rspec', '~> 1.8'
  s.add_development_dependency 'solr_wrapper', '~> 2.0'
end
