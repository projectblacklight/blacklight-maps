require 'spec_helper'

feature 'Initial view parameter', js: true do
  before :all do
    CatalogController.configure_blacklight do |config|
      config.view.maps.facet_mode = 'coordinates'
      config.view.maps.coordinates_facet_field = 'coordinates_facet'
      config.add_facet_field 'coordinates_facet', :limit => -2, :label => 'Coordinates', :show => false
    end
  end
  scenario 'defaults to zoom area of markers' do
    visit search_catalog_path f: { format: ['Book'] }, view: 'maps'
    expect(page).to have_css '.leaflet-marker-icon.marker-cluster', count: 8
  end
  scenario 'when provided sets map to its view' do
    map_tag = '<div id="blacklight-index-map" data-initialview="[[37.65, -122.56],[37.89, -122.27]]" data-maxzoom="18" data-tileurl="http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" data-mapattribution="Map data &amp;copy; &lt;a href=&quot;http://openstreetmap.org&quot;&gt;OpenStreetMap&lt;/a&gt; contributors, &lt;a href=&quot;http://creativecommons.org/licenses/by-sa/2.0/&quot;&gt;CC-BY-SA&lt;/a&gt;" data-searchcontrol="true" data-catalogpath="/catalog" data-placenamefield="placename_field" data-clustercount="hits" />'.html_safe
    expect_any_instance_of(Blacklight::BlacklightMapsHelperBehavior).to receive(:blacklight_map_tag).and_return(map_tag)
    visit search_catalog_path f: { format: ['Book'] }, view: 'maps'
    expect(page).to_not have_css '.leaflet-marker-icon.marker-cluster'
  end
end
