# frozen_string_literal: true

require 'spec_helper'

describe BlacklightMaps::GeojsonExport do
  let(:controller) { CatalogController.new }
  let(:action) { :index }
  let(:response_docs) do
    YAML.safe_load(File.open(File.join(fixture_path, 'sample_solr_documents.yml')))
  end
  before(:each) { controller.request = ActionDispatch::TestRequest.create }

  subject do
    described_class.new(controller, action, response_docs, { foo: 'bar' })
  end

  it 'instantiates a GeojsonExport instance' do
    expect(subject.class).to eq(::BlacklightMaps::GeojsonExport)
  end

  describe 'return config settings' do
    it 'returns maps config' do
      expect(subject.send(:maps_config).class).to eq(::Blacklight::Configuration::ViewConfig)
    end

    it 'returns geojson_field' do
      expect(subject.send(:geojson_field)).to eq('geojson_ssim')
    end

    it 'returns coordinates_field' do
      expect(subject.send(:coordinates_field)).to eq('coordinates_srpt')
    end

    it 'creates an @options instance variable' do
      expect(subject.instance_variable_get('@options')[:foo]).to eq('bar')
    end
  end

  describe 'build_feature_from_geojson' do
    describe 'point feature' do
      let(:geojson) { '{"type":"Feature","geometry":{"type":"Point","coordinates":[104.195397,35.86166]},"properties":{"placename":"China"}}' }
      let(:point_feature) { subject.send(:build_feature_from_geojson, geojson, 1) }

      it 'has a hits property with the right value' do
        expect(point_feature[:properties][:hits]).to eq(1)
      end

      it 'has a popup property' do
        expect(point_feature[:properties]).to have_key(:popup)
      end
    end

    describe 'bbox feature' do
      describe 'catalog#index view' do
        let(:geojson) { '{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[68.162386, 6.7535159], [97.395555, 6.7535159], [97.395555, 35.5044752], [68.162386, 35.5044752], [68.162386, 6.7535159]]]},"bbox":[68.162386, 6.7535159, 97.395555, 35.5044752]}' }
        let(:bbox_feature) { subject.send(:build_feature_from_geojson, geojson, 1) }

        it 'sets the center point as the coordinates' do
          expect(bbox_feature[:geometry][:coordinates]).to eq([82.7789705, 21.12899555])
        end

        it "changes the geometry type to 'Point'" do
          expect(bbox_feature[:geometry][:type]).to eq('Point')
          expect(bbox_feature[:bbox]).to be_nil
        end
      end
    end
  end

  describe 'build_feature_from_coords' do
    describe 'point feature' do
      let(:point_feature) { subject.send(:build_feature_from_coords, '35.86166,104.195397', 1) }

      it 'creates a GeoJSON feature hash' do
        expect(point_feature.class).to eq(Hash)
        expect(point_feature[:type]).to eq('Feature')
      end

      it 'has the right coordinates' do
        expect(point_feature[:geometry][:coordinates]).to eq([104.195397, 35.86166])
      end

      it 'has a hits property with the right value' do
        expect(point_feature[:properties][:hits]).to eq(1)
      end

      it 'has a popup property' do
        expect(point_feature[:properties]).to have_key(:popup)
      end
    end

    describe 'bbox feature' do
      let(:basic_bbox) { 'ENVELOPE(68.162386, 97.395555, 35.5044752, 6.7535159)' }
      describe 'catalog#index view' do
        let(:bbox_feature) { subject.send(:build_feature_from_coords, basic_bbox, 1) }

        it 'sets the center point as the coordinates' do
          expect(bbox_feature[:geometry][:type]).to eq('Point')
          expect(bbox_feature[:geometry][:coordinates]).to eq([82.7789705, 21.12899555])
        end

        describe 'bounding box that crosses the dateline' do
          let(:bbox_feature) do
            subject.send(:build_feature_from_coords,
                         'ENVELOPE(1.162386, -179.395555, 35.5044752, 6.7535159)', 1)
          end

          it 'sets a center point with a long value between -180 and 180' do
            expect(bbox_feature[:geometry][:coordinates]).to eq([90.88341550000001,21.12899555])
          end
        end
      end

      describe 'catalog#show view' do
        let(:action) { :show }
        let(:show_feature) { subject.send(:build_feature_from_coords, basic_bbox, 1) }

        it 'should convert the bbox string to a polygon coordinate array' do
          expect(show_feature[:geometry][:type]).to eq('Polygon')
          expect(show_feature[:geometry][:coordinates]).to eq(
            [[[68.162386, 6.7535159], [97.395555, 6.7535159], [97.395555, 35.5044752], [68.162386, 35.5044752], [68.162386, 6.7535159]]]
          )
        end

        it 'sets the bbox member' do
          expect(show_feature[:bbox]).to eq([68.162386, 6.7535159, 97.395555, 35.5044752])
        end
      end
    end
  end

  describe 'render_leaflet_popup_content' do
    describe 'placename_facet search_mode' do
      let(:placename_popup) do
        subject.send(:render_leaflet_popup_content,
                     { type: 'Feature',
                       geometry: { type: 'Point', coordinates:[104.195397,35.86166] },
                       properties: { placename: 'China', hits:1 } })
      end
      it 'renders the map_placename_search partial if the placename is present' do
        expect(placename_popup).to include('href="/catalog?f%5Bsubject_geo_ssim%5D%5B%5D=China')
      end

      let(:spatial_popup) do
        subject.send(:render_leaflet_popup_content,
                     { type: 'Feature',
                       geometry: { type: 'Point', coordinates: [104.195397,35.86166] },
                       properties: { hits: 1 } })
      end
      it 'renders the map_spatial_search partial if the placename is not present' do
        expect(spatial_popup).to include('href="/catalog?coordinates=35.86166%2C104.195397&amp;spatial_search_type=point')
      end
    end

    describe 'coordinates search_mode' do
      before(:each) do
        CatalogController.configure_blacklight do |config|
          config.view.maps.search_mode = 'coordinates'
        end
      end

      let(:spatial_popup) do
        subject.send(:render_leaflet_popup_content,
                     { type: 'Feature',
                       geometry: { type: 'Point', coordinates: [104.195397,35.86166] },
                       properties: { hits: 1 } })
      end
      it 'renders the map_spatial_search partial' do
        expect(spatial_popup).to include('href="/catalog?coordinates=35.86166%2C104.195397&amp;spatial_search_type=point')
      end
    end
  end

  describe 'build_geojson_features' do
    let(:geojson_features) do
      described_class.new(controller, :show, response_docs.first).send(:build_geojson_features)
    end
    it 'creates an array of system' do
      expect(geojson_features).to_not be_blank
    end
  end

  describe 'to_geojson' do
    let(:feature_collection) do
      described_class.new(controller, :show, response_docs.first).send(:to_geojson)
    end
    it 'renders feature collection as json' do
      expect(feature_collection).to include('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point"')
    end
  end
end
