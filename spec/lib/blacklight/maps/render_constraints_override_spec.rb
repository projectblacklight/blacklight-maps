# frozen_string_literal: true

require 'spec_helper'

describe BlacklightMaps::RenderConstraintsOverride, type: :helper do
  let(:mock_controller) { CatalogController.new }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:test_params) { { coordinates: '35.86166,104.195397', spatial_search_type: 'point' } }
  let(:test_search_state) do
    Blacklight::SearchState.new(test_params, blacklight_config, mock_controller)
  end

  describe 'has_search_parameters?' do
    before { mock_controller.params = test_params }

    it 'returns true if coordinate params are present' do
      expect(mock_controller.has_search_parameters?).to be_truthy
    end
  end

  describe 'has_spatial_parameters?' do
    it 'returns true if coordinate params are present' do
      expect(helper.has_spatial_parameters?(test_search_state)).to be_truthy
    end
  end

  describe 'query_has_constraints?' do
    it 'returns true if there are coordinate params' do
      expect(helper.query_has_constraints?(test_search_state)).to be_truthy
    end
  end

  describe 'spatial_constraint_label' do
    let(:bbox_params) { { spatial_search_type: 'bbox' } }

    it 'returns the point label' do
      expect(helper.spatial_constraint_label(test_search_state)).to eq(I18n.t('blacklight.search.filters.coordinates.point'))
    end

    it 'returns the bbox label' do
      expect(helper.spatial_constraint_label(bbox_params)).to eq(I18n.t('blacklight.search.filters.coordinates.bbox'))
    end
  end

  describe 'render spatial constraints' do
    describe 'render_spatial_query' do
      before do
        allow(helper).to receive_messages(search_action_path: search_catalog_path)
      end

      it 'renders the coordinates' do
        expect(helper.render_spatial_query(test_search_state)).to have_content(test_params[:coordinates])
      end

      it 'removes the spatial params' do
        expect(helper.remove_spatial_params(test_search_state)).not_to have_content('spatial_search_type')
      end
    end

    describe 'render_search_to_s_coord' do
      it 'returns render_search_to_s_element when coordinates are present' do
        expect(helper).to receive(:render_search_to_s_element)
        expect(helper).to receive(:render_filter_value)
        helper.render_search_to_s_coord(test_params)
      end
    end
  end
end
