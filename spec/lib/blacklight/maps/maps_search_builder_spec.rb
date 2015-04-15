require 'spec_helper'

describe BlacklightMaps::MapsSearchBuilder do

  class MapsSearchBuilderTestClass
    cattr_accessor :blacklight_config, :blacklight_params

    include Blacklight::SearchHelper
    include BlacklightMaps::MapsSearchBuilder

    def initialize blacklight_config, blacklight_params
      self.blacklight_config = blacklight_config
      self.blacklight_params = blacklight_params
    end

  end

  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:blacklight_params) { Hash.new }
  let(:solr_parameters) { Blacklight::Solr::Request.new }

  describe "add_spatial_search_to_solr" do

    before { @obj = MapsSearchBuilderTestClass.new blacklight_config, blacklight_params }

    describe "coordinate search" do

      before do
        @obj.blacklight_params[:coordinates] = "35.86166,104.195397"
        @obj.blacklight_params[:spatial_search_type] = "point"
      end

      it "should return a coordinate point spatial search if coordinates are given" do
        expect(@obj.add_spatial_search_to_solr(solr_parameters)[:fq].first).to include('geofilt')
        expect(@obj.add_spatial_search_to_solr(solr_parameters)[:pt]).to eq(@obj.blacklight_params[:coordinates])
      end

    end

    describe "bbox search" do

      before do
        @obj.blacklight_params[:coordinates] = "[6.7535159,68.162386 TO 35.5044752,97.395555]"
        @obj.blacklight_params[:spatial_search_type] = "bbox"
      end

      it "should return a bbox spatial search if a bbox is given" do
        expect(@obj.add_spatial_search_to_solr(solr_parameters)[:fq].first).to include(blacklight_config.view.maps.coordinates_field)
      end

    end

  end

end