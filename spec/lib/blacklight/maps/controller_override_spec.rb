require 'spec_helper'

describe BlacklightMaps::ControllerOverride do

  class BlacklightMapsControllerTestClass < CatalogController
  end

  before(:each) do
    CatalogController.blacklight_config = Blacklight::Configuration.new
    @fake_controller = BlacklightMapsControllerTestClass.new
    @fake_controller.extend(BlacklightMaps::ControllerOverride)
  end

  let(:solr_params) { OpenStruct.new }
  let(:req_params) { OpenStruct.new }

  describe "add_spatial_search_to_solr" do

    it "should return a coordinate point spatial search if coordinates are given" do
      req_params.coordinates = "35.86166,104.195397"
      req_params.spatial_search_type = "point"
      expect(@fake_controller.add_spatial_search_to_solr(solr_params, req_params).fq.first).to include('geofilt')
      expect(@fake_controller.add_spatial_search_to_solr(solr_params, req_params).pt).to eq(req_params.coordinates)
    end

    it "should return a bbox spatial search if a bbox is given" do
      req_params.coordinates = "[6.7535159,68.162386 TO 35.5044752,97.395555]"
      req_params.spatial_search_type = "bbox"
      expect(@fake_controller.add_spatial_search_to_solr(solr_params, req_params).fq.first).to include(CatalogController.blacklight_config.view.maps.coordinates_field)
    end

  end

end