# frozen_string_literal: true

namespace :blacklight_maps do
  namespace :index do
    desc 'Put sample data into solr'
    task seed: [:environment] do
      require 'yaml'
      gem_path = Gem::Specification.find_by_name('blacklight-maps').gem_dir
      docs = YAML.safe_load(File.read(File.join(gem_path, 'spec', 'fixtures', 'sample_solr_documents.yml')))
      conn = Blacklight.default_index.connection
      conn.add docs
      conn.commit
    end
  end
end
