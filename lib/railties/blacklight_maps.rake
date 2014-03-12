require 'rails/generators'
require 'generators/blacklight_maps/install_generator'

namespace :blacklight_maps do
  namespace :solr do
    desc "Put sample data into solr"
    task :seed => :environment do
      docs = YAML::load(File.open(File.expand_path(File.join('..', '..', '..', 'spec', 'fixtures', 'sample_solr_documents.yml'), __FILE__)))
      Blacklight.solr.add docs
      Blacklight.solr.commit
    end
  end
end