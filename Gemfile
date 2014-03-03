source 'https://rubygems.org'

gem 'leaflet-rails'

gem 'leaflet-markercluster-rails', git: 'https://github.com/mejackreed/leaflet-markercluster-rails.git'

gem 'leaflet-sidebar-rails', git: 'https://github.com/mejackreed/leaflet-sidebar-rails.git'

# Specify your gem's dependencies in blacklight-maps.gemspec
gemspec
gem 'engine_cart', path: '/Users/cabeer/Projects/engine_cart'

file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path("../spec/internal", __FILE__))
if File.exists?(file)
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(file)
end