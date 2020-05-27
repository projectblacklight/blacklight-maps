# frozen_string_literal: true

require 'spec_helper'

describe BlacklightMaps::MapsSearchBuilderBehavior do
  let(:blacklight_config) { CatalogController.blacklight_config.deep_copy }
  let(:user_params) { {} }
  let(:context) { CatalogController.new }
  let(:search_builder_class) do
    Class.new(Blacklight::SearchBuilder) do
      include Blacklight::Solr::SearchBuilderBehavior
      include BlacklightMaps::MapsSearchBuilderBehavior
    end
  end
  let(:search_builder) { search_builder_class.new(context) }

  before { allow(context).to receive(:blacklight_config).and_return(blacklight_config) }

  describe 'add_spatial_search_to_solr' do
    describe 'coordinate search' do
      let(:coordinate_search) do
        search_builder.with(coordinates: '35.86166,104.195397', spatial_search_type: 'point')
      end

      it 'returns a coordinate point spatial search if coordinates are given' do
        expect(coordinate_search[:fq].first).to include('geofilt')
        expect(coordinate_search[:pt]).to eq('35.86166,104.195397')
      end
    end

    describe 'bbox search' do
      let(:bbox_search) do
        search_builder.with(coordinates: '[6.7535159,68.162386 TO 35.5044752,97.395555]',
                            spatial_search_type: 'bbox')
      end

      it 'returns a bbox spatial search if a bbox is given' do
        expect(bbox_search[:fq].first).to include(blacklight_config.view.maps.coordinates_field)
      end
    end
  end
end
