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

  s.add_dependency 'blacklight', '>= 7.8.0', '< 8'
  s.add_dependency 'rails', '>= 7.0', '< 8'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'engine_cart', '~> 2.6'
  s.add_development_dependency 'rspec-rails', '~> 7.1'
  s.add_development_dependency 'rubocop', '~> 1.72.2'
  s.add_development_dependency 'rubocop-rspec', '~> 3.4'
  s.add_development_dependency 'selenium-webdriver', '~> 4.0'
  s.add_development_dependency 'solr_wrapper', '~> 4.1'
end
