require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "../../spec/test_app_templates"

  def remove_index 
    remove_file "public/index.html"
  end

  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)

    Bundler.with_clean_env do
      run "bundle install"
    end

    generate 'blacklight:install'
  end

  def run_gallery_install
    generate 'blacklight_maps:install'
  end

  def configure_test_assets
    insert_into_file 'config/environments/test.rb', :after => 'Rails.application.configure do' do
      %q{
  config.assets.digest = false
}
    end
  end

end
