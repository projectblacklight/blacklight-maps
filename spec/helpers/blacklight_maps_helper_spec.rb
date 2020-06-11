# frozen_string_literal: true

require 'spec_helper'

describe BlacklightMapsHelper do
  let(:query_term) { 'Tibet' }
  let(:mock_controller) { CatalogController.new }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:maps_config) { blacklight_config.view.maps }
  let(:search_service) do
    Blacklight::SearchService.new(config: blacklight_config, user_params: { q: query_term })
  end
  let(:response) { search_service.search_results[0] }
  let(:docs) { response.aggregations[maps_config.geojson_field].items }
  let(:coords) { [91.117212, 29.646923] }
  let(:geojson_hash) do
    { type: 'Feature', geometry: { type: 'Point', coordinates: coords }, properties: { placename: query_term } }
  end
  let(:bbox) { [78.3955448, 26.8548157, 99.116241, 36.4833345] }

  before do
    mock_controller.request = ActionDispatch::TestRequest.create
    allow(helper).to receive_messages(controller: mock_controller, action_name: 'index')
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
    allow(helper).to receive_messages(blacklight_configuration_context: Blacklight::Configuration::Context.new(mock_controller))
    allow(helper).to receive(:search_state).and_return Blacklight::SearchState.new({}, blacklight_config, mock_controller)
    blacklight_config.add_facet_field 'geojson_ssim', limit: -2, label: 'GeoJSON', show: false
    blacklight_config.add_facet_fields_to_solr_request!
  end

  describe 'blacklight_map_tag' do
    context 'with default values' do
      subject { helper.blacklight_map_tag('blacklight-map') }

      it { is_expected.to have_selector 'div#blacklight-map' }
      it { is_expected.to have_selector "div[data-maxzoom='#{maps_config.maxzoom}']" }
      it { is_expected.to have_selector "div[data-tileurl='#{maps_config.tileurl}']" }
      it { is_expected.to have_selector "div[data-mapattribution='#{maps_config.mapattribution}']" }
    end

    context 'with custom values' do
      subject { helper.blacklight_map_tag('blacklight-map', data: { maxzoom: 6, tileurl: 'http://example.com/', mapattribution: 'hello world' }) }

      it { is_expected.to have_selector "div[data-maxzoom='6'][data-tileurl='http://example.com/'][data-mapattribution='hello world']" }
    end

    context 'when a block is provided' do
      subject { helper.blacklight_map_tag('foo') { content_tag(:span, 'bar') } }

      it { is_expected.to have_selector('div > span', text: 'bar') }
    end
  end

  describe 'serialize_geojson' do
    it 'returns geojson of documents' do
      expect(helper.serialize_geojson(docs)).to include('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point"')
    end
  end

  describe 'placename_value' do
    it 'returns the placename value' do
      expect(helper.placename_value(geojson_hash)).to eq(query_term)
    end
  end

  describe 'link_to_bbox_search' do
    it 'creates a spatial search link' do
      expect(helper.link_to_bbox_search(bbox)).to include('catalog?coordinates')
      expect(helper.link_to_bbox_search(bbox)).to include('spatial_search_type=bbox')
    end

    it 'includes the default_document_index_view_type in the params' do
      expect(helper.link_to_bbox_search(bbox)).to include('view=list')
    end
  end

  describe 'link_to_placename_field' do
    subject { helper.link_to_placename_field(query_term, maps_config.placename_field) }

    it { is_expected.to include("catalog?f%5B#{maps_config.placename_field}%5D%5B%5D=Tibet") }
    it { is_expected.to include('view=list') }

    it 'creates a link to the placename field using the display value' do
      expect(helper.link_to_placename_field(query_term, maps_config.placename_field, 'foo')).to include('">foo</a>')
    end
  end

  describe 'link_to_point_search' do
    it 'creates a link to a coordinate point' do
      expect(helper.link_to_point_search(coords)).to include('catalog?coordinates')
      expect(helper.link_to_point_search(coords)).to include('spatial_search_type=point')
    end

    it 'includes the default_document_index_view_type in the params' do
      expect(helper.link_to_point_search(coords)).to include('view=list')
    end
  end

  describe 'render_placename_heading' do
    it 'returns the placename heading' do
      expect(helper.render_placename_heading(geojson_hash)).to eq(query_term)
    end
  end

  describe 'render_index_mapview' do
    before { helper.instance_variable_set(:@response, response) }

    it 'renders the "catalog/index_mapview" partial' do
      expect(helper.render_index_mapview).to include("$('#blacklight-index-map').blacklight_leaflet_map")
    end
  end

  describe 'render_spatial_search_link' do
    it 'returns link_to_bbox_search if bbox coordinates are passed' do
      expect(helper.render_spatial_search_link(bbox)).to include('spatial_search_type=bbox')
    end

    it 'returns link_to_point_search if point coordinates are passed' do
      expect(helper.render_spatial_search_link(coords)).to include('spatial_search_type=point')
    end
  end
end
