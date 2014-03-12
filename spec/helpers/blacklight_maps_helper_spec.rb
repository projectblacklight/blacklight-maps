require 'spec_helper'

describe BlacklightMapsHelper do
  include ERB::Util
  include BlacklightMapsHelper

  let(:blacklight_config) { Blacklight::Configuration.new }
 
  describe "show_map_div" do
    before :each do
      helper.stub(blacklight_config: blacklight_config)
    end

    it "should have #map div" do
      expect(helper.show_map_div).to have_selector("div#blacklight-map")
    end

    it "should contain data-attributes" do
      expect(helper.show_map_div).to have_selector("div[data-maxzoom='8']")
    end

  end

  # TODO Test geoJSON serialization
 
  

end