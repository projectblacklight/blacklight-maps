# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BlacklightMaps::SpatialFilterQuery do
  let(:bbox_coords) { '[33.413102,68.093262 TO 42.892064,89.318848]' }
  let(:point_coords) { '36,127' }
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_facet_field :coordinates,
                             filter_class: BlacklightMaps::CoordinatesFilterField,
                             filter_query_builder: described_class
    end
  end
  let(:search_state) { Blacklight::SearchState.new(params.with_indifferent_access, blacklight_config, double) }
  let(:filter) { search_state.filter(:coordinates) }
  let(:context) { CatalogController.new }
  let(:search_builder_class) do
    Class.new(Blacklight::SearchBuilder) do
      include Blacklight::Solr::SearchBuilderBehavior
    end
  end
  let(:search_builder) { search_builder_class.new(context) }

  describe '.call' do
    context 'with no coordinates' do
      let(:params) { {} }

      it 'returns nil fq' do
        fq, subqueries = described_class.call(search_builder, filter, {})
        expect(fq).to be_nil
        expect(subqueries).to be_nil
      end
    end

    context 'with bbox coordinates' do
      let(:params) { { coordinates: bbox_coords, spatial_search_type: 'bbox' } }
      let(:coordinates_field) { blacklight_config.view.maps.coordinates_field }

      it 'returns the field:value fq' do
        fq, subqueries = described_class.call(search_builder, filter, {})
        expect(fq).to eq("#{coordinates_field}:#{bbox_coords}")
        expect(subqueries).to be_nil
      end
    end

    context 'with point coordinates' do
      let(:params) { { coordinates: point_coords, spatial_search_type: 'point' } }

      it 'returns a geofilt fq' do
        fq, = described_class.call(search_builder, filter, {})
        expect(fq).to eq("{!geofilt sfield=#{blacklight_config.view.maps.coordinates_field}}")
      end

      it 'returns pt and d as subqueries' do
        _, subqueries = described_class.call(search_builder, filter, {})
        expect(subqueries).to include(pt: point_coords, d: blacklight_config.view.maps.spatial_query_dist)
      end
    end
  end
end
