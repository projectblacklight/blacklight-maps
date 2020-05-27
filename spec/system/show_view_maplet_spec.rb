# frozen_string_literal: true

require 'spec_helper'

describe 'catalog#show view', js: true do
  before(:all) do
    CatalogController.blacklight_config = Blacklight::Configuration.new
    CatalogController.configure_blacklight do |config|
      config.show.partials << :show_maplet # add maplet to show view partials
    end
  end

  describe 'item with point feature' do
    before { visit solr_document_path('00314247') }

    it 'displays the maplet' do
      expect(page).to have_selector('#blacklight-show-map-container')
    end

    it 'has a single marker icon' do
      expect(page).to have_selector('.leaflet-marker-icon', count: 1)
    end

    describe 'click marker icon' do
      before { find('.leaflet-marker-icon').click }

      it 'shows a popup with correct content' do
        expect(page).to have_selector('div.leaflet-popup-content-wrapper')
        expect(page).to have_content('Japan')
      end
    end
  end

  describe 'item with point and bbox system' do
    before { visit solr_document_path('2008308175') }

    it 'shows the correct mapped item count' do
      expect(page).to have_selector('.mapped-count .badge', text: '2')
    end

    it 'shows a bounding box and a point marker' do
      expect(page).to have_selector('.leaflet-overlay-pane path.leaflet-interactive')
      expect(page).to have_selector('.leaflet-marker-icon')
    end

    describe 'click bbox path' do
      before do
        0.upto(4) { find('a.leaflet-control-zoom-in').click } # so bbox not covered by point
        find('.leaflet-overlay-pane svg').click
      end

      it 'shows a popup with correct content' do
        expect(page).to have_selector('div.leaflet-popup-content-wrapper')
        expect(page).to have_content('[68.162386, 6.7535159, 97.395555, 35.5044752]')
      end
    end
  end

  describe 'item with bbox feature' do
    before do
      CatalogController.configure_blacklight do |config|
        # set zoom config so we can test whether setMapBounds() is correct
        config.view.maps.maxzoom = 8
        config.view.maps.show_initial_zoom = 10
      end
      visit solr_document_path('2009373514')
    end

    it 'displays a bounding box' do
      expect(page).to have_selector('.leaflet-overlay-pane path.leaflet-interactive')
    end

    it 'zooms to the correct map bounds' do
      # if setMapBounds() zoom >= maxzoom, zoom-in control will be disabled
      expect(page).to have_selector('a.leaflet-control-zoom-in.leaflet-disabled')
    end
  end
end
