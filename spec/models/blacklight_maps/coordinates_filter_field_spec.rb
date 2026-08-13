# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BlacklightMaps::CoordinatesFilterField do
  subject(:filter) { search_state.filter(:coordinates) }

  let(:bbox_coords) { '[33.413102,68.093262 TO 42.892064,89.318848]' }
  let(:point_coords) { '36,127' }
  let(:params) { {} }
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_facet_field :coordinates, filter_class: described_class
    end
  end
  let(:search_state) { Blacklight::SearchState.new(params.with_indifferent_access, blacklight_config) }

  describe '#permitted_params' do
    it 'permits both coordinates and spatial_search_type' do
      field = described_class.new(blacklight_config.facet_fields['coordinates'], search_state)
      expect(field.permitted_params).to include(:coordinates, :spatial_search_type)
    end
  end

  describe '#values' do
    context 'with no coordinates' do
      it { expect(filter.values).to be_empty }
    end

    context 'with bbox coordinates' do
      let(:params) { { coordinates: bbox_coords, spatial_search_type: 'bbox' } }

      it 'returns a single SpatialConstraintValue' do
        expect(filter.values.length).to eq(1)
      end

      it 'sets value to the coordinate string' do
        expect(filter.values.first.value).to eq(bbox_coords)
      end

      it 'sets label to the bbox i18n string' do
        expect(filter.values.first.label).to eq(I18n.t('blacklight.search.filters.coordinates.bbox'))
      end
    end

    context 'with point coordinates' do
      let(:params) { { coordinates: point_coords, spatial_search_type: 'point' } }

      it 'sets label to the point i18n string' do
        expect(filter.values.first.label).to eq(I18n.t('blacklight.search.filters.coordinates.point'))
      end
    end

    context 'when :filters is excluded' do
      let(:params) { { coordinates: bbox_coords, spatial_search_type: 'bbox' } }

      it { expect(filter.values(except: [:filters])).to be_empty }
    end
  end

  describe '#remove' do
    let(:params) { { coordinates: bbox_coords, spatial_search_type: 'bbox', q: 'tibet' } }

    it 'removes coordinates from the search state' do
      new_state = filter.remove(nil)
      expect(new_state.params[:coordinates]).to be_nil
    end

    it 'removes spatial_search_type from the search state' do
      new_state = filter.remove(nil)
      expect(new_state.params[:spatial_search_type]).to be_nil
    end

    it 'preserves other params' do
      new_state = filter.remove(nil)
      expect(new_state.params[:q]).to eq('tibet')
    end
  end
end
