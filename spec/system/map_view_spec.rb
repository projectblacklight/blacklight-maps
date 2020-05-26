# frozen_string_literal: true

require 'spec_helper'

describe 'catalog#map view', js: true do
  before(:each) do
    CatalogController.blacklight_config = Blacklight::Configuration.new
    CatalogController.configure_blacklight do |config|
      # use coordinates_facet facet for blacklight-maps catalog#map view specs
      config.view.maps.facet_mode = 'coordinates'
      config.view.maps.coordinates_facet_field = 'coordinates_ssim'
      config.add_facet_field 'coordinates_ssim', limit: -2, label: 'Coordinates', show: false
      config.add_facet_fields_to_solr_request!
    end
    visit map_path
  end

  it 'displays map elements' do
    expect(page).to have_selector('#documents.map')
    expect(page).to have_selector('#blacklight-index-map')
  end

  it 'displays some markers' do
    expect(page).to have_selector('div.marker-cluster')
  end

  describe 'marker popups' do
    before(:each) do
      #0.upto(1) { find('a.leaflet-control-zoom-in').click } # zoom in
      #save_screenshot # TODO: specs below fail without this, figure out why
      2.times do # zoom out to create cluster
        find('a.leaflet-control-zoom-in').click
        sleep(1) # give Leaflet time to split clusters or spec can fail
      end
      find('.marker-cluster:first-child').click
    end

    it 'shows a popup with correct content' do
      expect(page).to have_selector('.leaflet-popup-content-wrapper')
      expect(page).to have_css('.geo_popup_heading', text: '[35.86166, 104.195397]')
    end

    describe 'click search link' do
      before { find('div.leaflet-popup-content a').click }

      it 'runs a new search' do
        expect(page).to have_selector('.constraint-value .filter-value', text: '35.86166,104.195397')
        expect(current_url).to include('view=list')
      end
    end
  end
end
