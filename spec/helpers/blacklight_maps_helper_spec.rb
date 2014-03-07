require 'spec_helper'

describe BlacklightMapsHelper do
  include ERB::Util
  include BlacklightMapsHelper

  let(:blacklight_config) { Blacklight::Configuration.new }
 
  describe "has_thumbnail_field_defined?" do
    before :each do
      helper.stub(blacklight_config: blacklight_config)
    end


    it "should return false if thumbnail field is not defined (default)" do
      expect(helper.has_thumbnail_field_defined?()).to be_false
    end
    
    it "should return true if thumbnail field is defined" do
      blacklight_config.view.maps.stub(:thumbnail_field => "thumb_field_name")
      expect(helper.has_thumbnail_field_defined?()).to be_true
    end
  end

  describe "show_map_div" do
    before :each do
      helper.stub(blacklight_config: blacklight_config)
    end

    it "should have #map div" do
      expect(helper.show_map_div).to have_selector("div#map")
    end

    it "should contain data-attributes" do
      expect(helper.show_map_div).to have_selector("div[data-maxzoom='8']")
    end

    it "should not contain thumbnail_field selector" do
      expect(helper.show_map_div).not_to have_selector("div[data-thumbfield=thumb_field_name]")
    end

    it "should contain thumbnail_field selector" do
      blacklight_config.view.maps.stub(:thumbnail_field => "thumb_field_name")
      expect(helper.show_map_div).to have_selector("div[data-thumbfield=thumb_field_name]")
    end
  end

  # TODO Not really sure what the best way is to test this
  # describe "send_needed_map_fields" do
  #   before { visit catalog_index_path :q => 'tibet', :view => 'maps' }

  #   it "should return 10 documents" do
  #     puts page.send_needed_map_fields
  #     expect(page.send_needed_map_fields.length).to eq(10)
  #   end

  # end

  

end