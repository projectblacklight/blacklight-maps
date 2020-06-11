# frozen_string_literal: true

require 'spec_helper'

describe 'catalog#index map view', js: true do
  before do
    CatalogController.blacklight_config = Blacklight::Configuration.new
    CatalogController.configure_blacklight do |config|
      # use geojson facet for blacklight-maps catalog#index map view specs
      config.add_facet_field 'geojson_ssim', limit: -2, label: 'GeoJSON', show: false
      config.add_facet_fields_to_solr_request!
    end
    visit search_catalog_path q: 'korea', view: 'maps'
  end

  it 'displays map elements' do
    expect(page).to have_selector('#documents.map')
    expect(page).to have_selector('#blacklight-index-map')
  end

  it 'displays tile layer attribution' do
    expect(find('div.leaflet-control-container')).to have_content('OpenStreetMap contributors, CC-BY-SA')
  end

  describe '#sortAndPerPage' do
    it 'shows the mapped item count' do
      expect(page).to have_selector('.mapped-count .badge', text: '4')
    end

    it 'shows the mapped item caveat' do
      expect(page).to have_selector('.mapped-caveat')
    end

    # TODO: placeholder spec: #sortAndPerPage > .view-type > .view-type-group
    # shows active map icon. however, this spec doesn't work because
    # Blacklight::ConfigurationHelperBehavior#has_alternative_views? returns false,
    # so catalog/_view_type_group partial renders no content, can't figure out why
    it 'shows the map view icon' do
      pending("expect(page).to have_selector('.view-type-maps.active')")
      fail
    end
  end

  describe 'data attributes' do
    let(:maxzoom) { CatalogController.blacklight_config.view.maps.maxzoom }
    let(:tileurl) { CatalogController.blacklight_config.view.maps.tileurl }

    it 'has maxzoom value from config' do
      expect(page).to have_selector("#blacklight-index-map[data-maxzoom='#{maxzoom}']")
    end

    it 'has tileurl value from config' do
      expect(page).to have_selector("#blacklight-index-map[data-tileurl='#{tileurl}']")
    end
  end

  describe 'marker clusters' do
    before do
      3.times do # zoom out to create cluster
        find('a.leaflet-control-zoom-out').click
        sleep(1) # give Leaflet time to combine clusters or spec can fail
      end
    end

    it 'has one marker cluster' do
      expect(page).to have_selector('div.marker-cluster', count: 1)
    end

    it 'shows the result count' do
      expect(find('div.marker-cluster')).to have_content(4)
    end

    describe 'click marker cluster' do
      before { find('div.marker-cluster').click }

      it 'splits into two marker clusters' do
        expect(page).to have_selector('div.marker-cluster', count: 2)
      end
    end
  end

  describe 'marker popups' do
    before do
      find('.marker-cluster', text: '1', match: :first).click
    end

    it 'shows a popup with correct content' do
      expect(page).to have_selector('div.leaflet-popup-content-wrapper')
      expect(page).to have_css('.geo_popup_heading', text: 'Seoul (Korea)')
    end

    describe 'click search link' do
      before { find('div.leaflet-popup-content a').click }

      it 'runs a new search' do
        expect(page).to have_selector('.constraint-value .filter-value', text: 'Seoul (Korea)')
      end

      it 'uses the default view type' do
        expect(current_url).to include('view=list')
      end
    end
  end

  describe 'map search control' do
    it 'has a search control' do
      expect(page).to have_selector('.leaflet-control .search-control')
    end

    describe 'search control hover' do
      before { find('.search-control').hover }

      it 'adds a border to the map' do
        expect(page).to have_selector('.leaflet-overlay-pane path')
      end
    end

    describe 'search control click' do
      before { find('.search-control').click }

      it 'runs a new search' do
        expect(page).to have_selector('.constraint.coordinates')
        expect(current_url).to include('view=list')
      end
    end
  end
end
