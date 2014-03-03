require "bundler/gem_tasks"

ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.6.0.zip"
APP_ROOT = File.dirname(__FILE__)

require 'rspec/core/rake_task'
require 'engine_cart/rake_task'

require 'jettywrapper'
require 'blacklight'

task default: :ci

desc "Load fixtures"
task :fixtures => ['engine_cart:generate'] do
  EngineCart.within_test_app do
    system "rake solr:seed RAILS_ENV=test"
    abort "Error running fixtures" unless $?.success?
  end
end

desc "Execute Continuous Integration build"
task :ci => ['jetty:clean', 'engine_cart:generate'] do

  require 'jettywrapper'
  jetty_params = {
    :jetty_home => File.expand_path(File.dirname(__FILE__) + '/jetty'),
    :quiet => false,
    :jetty_port => 8888,
    :solr_home => File.expand_path(File.dirname(__FILE__) + '/jetty/solr'),
    :startup_wait => 30
  }

  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['fixtures'].invoke
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end


namespace :solr do
  desc "Put sample data into solr"
  task :seed do
    docs = YAML::load(File.open(File.expand_path('..', 'spec', 'fixtures', 'sample_solr_documents.yml', __FILE__)))
    Blacklight.solr.add docs
    Blacklight.solr.commit
  end
end
