# frozen_string_literal: true

require 'spec_helper'

describe CatalogController do
  render_views

  # test setting configuration defaults in Blacklight::Maps::Engine here
  describe 'maps config' do
    let(:maps_config) { described_class.blacklight_config.view.maps }

    it 'sets the defaults in blacklight_config' do
      %i[geojson_field placename_property coordinates_field search_mode spatial_query_dist
         placename_field coordinates_facet_field facet_mode tileurl mapattribution maxzoom
         show_initial_zoom].each do |config_method|
        expect(maps_config.send(config_method)).not_to be_blank
      end
    end
  end

  describe "GET 'map'" do
    before { get :map }

    it 'responds to the #map action' do
      expect(response.code).to eq '200'
    end

    it "renders the '/map' partial" do
      expect(response.body).to have_selector('#blacklight-index-map')
    end
  end
end
