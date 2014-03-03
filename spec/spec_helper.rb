ENV["RAILS_ENV"] ||= 'test'

require 'engine_cart'
EngineCart.load_application!

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 5

if ENV["COVERAGE"] or ENV["CI"]
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter "/spec/"
  end
end


require 'blacklight'
require 'blacklight/maps'

require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'


RSpec.configure do |config|

end