# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BlacklightMaps::SpatialItemPresenter do
  let(:bbox_coords) { '[33.413102,68.093262 TO 42.892064,89.318848]' }
  let(:bbox_label) { I18n.t('blacklight.search.filters.coordinates.bbox') }
  let(:facet_item) { BlacklightMaps::CoordinatesFilterField::SpatialConstraintValue.new(bbox_coords, bbox_label) }
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_facet_field :coordinates,
                             filter_class: BlacklightMaps::CoordinatesFilterField,
                             item_presenter: described_class,
                             label: 'Spatial Search'
    end
  end
  let(:facet_config) { blacklight_config.facet_fields['coordinates'] }
  let(:search_state) { Blacklight::SearchState.new({}.with_indifferent_access, blacklight_config) }
  let(:view_context) { Struct.new(:blacklight_config, :search_state).new(blacklight_config, search_state) }
  let(:presenter) { described_class.new(facet_item, facet_config, view_context, search_state) }

  describe '#field_label' do
    it 'returns the spatial type label from the facet item' do
      expect(presenter.field_label).to eq(bbox_label)
    end
  end

  describe '#constraint_label' do
    it 'returns the coordinate string from the facet item' do
      expect(presenter.constraint_label).to eq(bbox_coords)
    end
  end
end
