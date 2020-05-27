# frozen_string_literal: true

require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root './spec/test_app_templates'

  def install_engine
    generate 'blacklight_maps:install'
  end

  def configure_test_assets
    insert_into_file 'config/environments/test.rb', after: 'Rails.application.configure do' do
      "\nconfig.assets.digest = false"
    end
  end
end
