# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'BlacklightMaps'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

Rake::Task.define_task(:environment)

load 'lib/railties/blacklight_maps.rake'

task default: :ci

require 'engine_cart/rake_task'

require 'solr_wrapper'
require 'open3'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

def system_with_error_handling(*args)
  Open3.popen3(*args) do |_stdin, stdout, stderr, thread|
    puts stdout.read
    raise "Unable to run #{args.inspect}: #{stderr.read}" unless thread.value.success?
  end
end

def with_solr(&block)
  if ENV['SOLR_ENV'] == 'docker-compose'
    yield
  elsif system('docker compose version')
    begin
      puts 'Starting Solr'
      system_with_error_handling 'docker compose up -d --wait solr'
      yield
    ensure
      puts 'Stopping Solr'
      system_with_error_handling 'docker compose stop solr'
    end
  else
    SolrWrapper.wrap do |solr|
      solr.with_collection(&block)
    end
  end
end

desc 'Run test suite'
task ci: [:rubocop, 'engine_cart:generate'] do
  with_solr do
    within_test_app do
      system 'RAILS_ENV=test rake blacklight_maps:index:seed'
    end
    Rake::Task['spec'].invoke
  end
end
