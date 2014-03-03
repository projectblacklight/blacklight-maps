ENV["RAILS_ENV"] ||= 'test'

require 'blacklight'
require 'blacklight/maps'

require 'engine_cart'
EngineCart.load_application!

require 'rspec/rails'
require 'capybara/rspec'