require 'spec_helper'

describe BlacklightMaps::MapsSearchBuilderBehavior do

  let(:blacklight_config) { CatalogController.blacklight_config.deep_copy }
  let(:user_params) { Hash.new }
  let(:context) { CatalogController.new }

  before { allow(context).to receive(:blacklight_config).and_return(blacklight_config) }

  let(:search_builder_class) do
    Class.new(Blacklight::SearchBuilder) do
      include Blacklight::Solr::SearchBuilderBehavior
      include BlacklightMaps::MapsSearchBuilderBehavior
    end
  end

  let(:search_builder) { search_builder_class.new(context) }

  describe 'add_spatial_search_to_solr' do

    describe 'coordinate search' do

      subject { search_builder.with({coordinates: '35.86166,104.195397', spatial_search_type: 'point'}) }

      it 'should return a coordinate point spatial search if coordinates are given' do
        expect(subject[:fq].first).to include('geofilt')
        expect(subject[:pt]).to eq('35.86166,104.195397')
      end

    end

    describe 'bbox search' do

      subject { search_builder.with({coordinates: '[6.7535159,68.162386 TO 35.5044752,97.395555]',
                                     spatial_search_type: 'bbox'}) }

      it 'should return a bbox spatial search if a bbox is given' do
        expect(subject[:fq].first).to include(blacklight_config.view.maps.coordinates_field)
      end

    end

  end

end
