# frozen_string_literal: true

require 'spec_helper'

describe "BlacklightMaps::GeojsonExport" do

  before do
    CatalogController.blacklight_config = Blacklight::Configuration.new
    @controller = CatalogController.new
    @action = "index"
    @request = ActionDispatch::TestRequest.new
    @controller.request = @request
    @response = ActionDispatch::TestResponse.new
    expect(@response).to receive(:docs).and_return([{ "published_display"=>["Dharamsala, Distt. Kangra, H.P."], "pub_date"=>["2007"], "format"=>"Book", "title_display"=>"Ses yon", "material_type_display"=>["xii, 419 p."], "id"=>"2008308478", "placename_field"=>["China", "Tibet", "India"], "subject_topic_facet"=>["Education and state", "Tibetans", "Tibetan language", "Teaching"], "language_facet"=>["Tibetan"], "geojson"=>["{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[104.195397,35.86166]},\"properties\":{\"placename\":\"China\"}}", "{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[91.117212,29.646923]},\"properties\":{\"placename\":\"Tibet\"}}", "{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[78.96288,20.593684]},\"properties\":{\"placename\":\"India\"}}"], "coordinates"=>["68.162386 6.7535159 97.395555 35.5044752", "104.195397 35.86166", "91.117212 29.646923", "20.593684,78.96288"], "score"=>0.0026767207 }])
  end

  # TODO: use @response.facet_by_field_name('geojson').items instead of @response
  #       then refactor build_geojson_features and to_geojson specs
  subject {BlacklightMaps::GeojsonExport.new(@controller, @action, @response.docs, {foo:'bar'})}

  it "should instantiate GeojsonExport" do
    expect(subject.class).to eq(::BlacklightMaps::GeojsonExport)
  end

  describe "return config settings" do

    it "should return maps config" do
      expect(subject.send(:blacklight_maps_config).class).to eq(::Blacklight::Configuration::ViewConfig)
    end

    it "should return geojson_field" do
      expect(subject.send(:geojson_field)).to eq('geojson')
    end

    it "should return coordinates_field" do
      expect(subject.send(:coordinates_field)).to eq('coordinates')
    end

    it "should return search_mode" do
      expect(subject.send(:search_mode)).to eq('placename')
    end

    it "should return facet_mode" do
      expect(subject.send(:facet_mode)).to eq('geojson')
    end

    it "should return placename_property" do
      expect(subject.send(:placename_property)).to eq('placename')
    end

    it "should create an @options instance variable" do
      expect(subject.instance_variable_get("@options")[:foo]).to eq('bar')
    end

  end

  describe "build_feature_from_geojson" do

    describe "point feature" do

      before do
        @output = subject.send(:build_feature_from_geojson, '{"type":"Feature","geometry":{"type":"Point","coordinates":[104.195397,35.86166]},"properties":{"placename":"China"}}', 1)
      end

      it "should have a hits property with the right value" do
        expect(@output[:properties]).to have_key(:hits)
        expect(@output[:properties][:hits]).to eq(1)
      end

      it "should have a popup property" do
        expect(@output[:properties]).to have_key(:popup)
      end

    end

    describe "bbox feature" do

      describe "catalog#index view" do

        before do
          @output = subject.send(:build_feature_from_geojson, '{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[68.162386, 6.7535159], [97.395555, 6.7535159], [97.395555, 35.5044752], [68.162386, 35.5044752], [68.162386, 6.7535159]]]},"bbox":[68.162386, 6.7535159, 97.395555, 35.5044752]}', 1)
        end

        it "should set the center point as the coordinates" do
          expect(@output[:geometry][:coordinates]).to eq([82.7789705, 21.12899555])
        end

        it "should change the geometry type to 'Point'" do
          expect(@output[:geometry][:type]).to eq("Point")
          expect(@output[:bbox]).to be_nil
        end

      end

    end

  end

  describe "build_feature_from_coords" do

    describe "point feature" do

      before do
        @output = subject.send(:build_feature_from_coords, '35.86166,104.195397', 1)
      end

      it "should create a GeoJSON feature hash" do
        expect(@output.class).to eq(Hash)
        expect(@output[:type]).to eq("Feature")
      end

      it "should have the right coordinates" do
        expect(@output[:geometry][:coordinates]).to eq([104.195397, 35.86166])
      end

      it "should have a hits property with the right value" do
        expect(@output[:properties]).to have_key(:hits)
        expect(@output[:properties][:hits]).to eq(1)
      end

      it "should have a popup property" do
        expect(@output[:properties]).to have_key(:popup)
      end

    end

    describe "bbox feature" do

      describe "catalog#index view" do

        before do
          @output = subject.send(:build_feature_from_coords, '68.162386 6.7535159 97.395555 35.5044752', 1)
        end

        it "should set the center point as the coordinates" do
          expect(@output[:geometry][:type]).to eq("Point")
          expect(@output[:geometry][:coordinates]).to eq([82.7789705, 21.12899555])
        end

        describe "bounding box that crosses the dateline" do

          before do
            @output = subject.send(:build_feature_from_coords, '1.162386 6.7535159 -179.395555 35.5044752', 1)
          end

          it "should set a center point with a long value between -180 and 180" do
            expect(@output[:geometry][:coordinates]).to eq([90.88341550000001,21.12899555])
          end

        end

      end

      describe "catalog#show view" do

        before do
          @action = "show"
          @output = subject.send(:build_feature_from_coords, '68.162386 6.7535159 97.395555 35.5044752', 1)
        end

        it "should convert the bbox string to a polygon coordinate array" do
          expect(@output[:geometry][:type]).to eq("Polygon")
          expect(@output[:geometry][:coordinates]).to eq([[[68.162386, 6.7535159], [97.395555, 6.7535159], [97.395555, 35.5044752], [68.162386, 35.5044752], [68.162386, 6.7535159]]])
        end

        it "should set the bbox member" do
          expect(@output[:bbox]).to eq([68.162386, 6.7535159, 97.395555, 35.5044752])
        end

      end

    end

  end

  describe "render_leaflet_popup_content" do

    describe "placename_facet search_mode" do

      it "should render the map_placename_search partial if the placename is present" do
        expect(subject.send(:render_leaflet_popup_content, {type:"Feature",geometry:{type:"Point",coordinates:[104.195397,35.86166]},properties:{placename:"China", hits:1}})).to include('href="/catalog?f%5Bplacename_field%5D%5B%5D=China')
      end

      it "should render the map_spatial_search partial if the placename is not present" do
        expect(subject.send(:render_leaflet_popup_content, {type:"Feature",geometry:{type:"Point",coordinates:[104.195397,35.86166]},properties:{hits:1}})).to include('href="/catalog?coordinates=35.86166%2C104.195397&amp;spatial_search_type=point')
      end

    end

    describe "coordinates search_mode" do

      before do
        CatalogController.configure_blacklight do |config|
          config.view.maps.search_mode = 'coordinates'
        end
      end

      it "should render the map_spatial_search partial" do
        expect(subject.send(:render_leaflet_popup_content, {type:"Feature",geometry:{type:"Point",coordinates:[104.195397,35.86166]},properties:{hits:1}})).to include('href="/catalog?coordinates=35.86166%2C104.195397&amp;spatial_search_type=point')
      end

    end

  end

  describe "build_geojson_features" do

    before do
      @action = "show"
    end

    it "should create an array of features" do
      expect(BlacklightMaps::GeojsonExport.new(@controller, @action, @response.docs[0]).send(:build_geojson_features).blank?).to be false
    end

  end

  describe "to_geojson" do

    before do
      @action = "show"
    end

    it "should render feature collection as json" do
      expect(BlacklightMaps::GeojsonExport.new(@controller, @action, @response.docs[0]).send(:to_geojson)).to include('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point"')
    end

  end

end
