# frozen_string_literal: true

require 'spec_helper'

describe 'Initial map bounds view parameter', :js do
  before(:all) do
    CatalogController.configure_blacklight do |config|
      config.view.maps.facet_mode = 'coordinates'
      config.view.maps.coordinates_facet_field = 'coordinates_ssim'
      config.add_facet_field 'coordinates_ssim', limit: -2, label: 'Coordinates', show: false
    end
  end

  it 'defaults to zoom area of markers' do
    visit search_catalog_path f: { format: ['Book'] }, view: 'maps'
    expect(page).to have_selector('.leaflet-marker-icon.marker-cluster', count: 9)
  end

  describe 'with provided initialview' do
    let(:map_tag) { '<div id="blacklight-index-map" data-initialview="[[37.65, -122.56],[37.89, -122.27]]" data-maxzoom="18" data-tileurl="http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" data-mapattribution="Map data &amp;copy; &lt;a href=&quot;http://openstreetmap.org&quot;&gt;OpenStreetMap&lt;/a&gt; contributors, &lt;a href=&quot;http://creativecommons.org/licenses/by-sa/2.0/&quot;&gt;CC-BY-SA&lt;/a&gt;" data-searchcontrol="true" data-catalogpath="/catalog" data-placenamefield="placename_field" data-clustercount="hits" />'.html_safe }

    it 'sets map to correct bounds when initialview provided' do
      allow_any_instance_of(Blacklight::BlacklightMapsHelperBehavior).to receive(:blacklight_map_tag).and_return(map_tag)
      visit search_catalog_path f: { format: ['Book'] }, view: 'maps'
      expect(page).not_to have_selector('.leaflet-marker-icon.marker-cluster')
    end
  end
end
