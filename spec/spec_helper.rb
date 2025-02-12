# frozen_string_literal: true

# testing environent:
ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
require 'coveralls'
Coveralls.wear!('rails')

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter '/spec/'
end

# engine_cart:
require 'bundler/setup'
require 'engine_cart'
EngineCart.load_application!

require 'blacklight/maps'

require 'rspec/rails'
require 'capybara/rspec'
require 'selenium-webdriver'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.fixture_paths = ["#{Blacklight::Maps.root}/spec/fixtures"]

  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1024, 768]
  end
end
