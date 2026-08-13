# frozen_string_literal: true

require 'spec_helper'

describe 'catalog#map view', :js do
  around do |example|
    original_config = CatalogController.blacklight_config
    begin
      CatalogController.blacklight_config = original_config.deep_copy
      CatalogController.configure_blacklight do |config|
        # use coordinates_facet facet for blacklight-maps catalog#map view specs
        config.view.maps.facet_mode = 'coordinates'
        config.view.maps.coordinates_facet_field = 'coordinates_ssim'
        config.add_facet_field 'coordinates_ssim', limit: -1, label: 'Coordinates', show: false
      end
      example.run
    ensure
      CatalogController.blacklight_config = original_config
    end
  end

  before do
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
    before do
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
        expect(page).to have_current_path(/view=list/)
      end
    end
  end
end
