require 'spec_helper'

describe "BlacklightMaps::GeojsonExport" do

  before do
    CatalogController.blacklight_config = Blacklight::Configuration.new
    CatalogController.configure_blacklight do |config|

      # These fields also need to be added for some reason for the tests to pass
      # Link in list is not being generated correctly if not passed
      config.index.title_field = 'title_display'
    end
    @controller = CatalogController.new
    @action = "index"
    @request = ActionDispatch::TestRequest.new
    @controller.request = @request
    @response = ActionDispatch::TestResponse.new
    @response.stub(:docs) {[{ "published_display"=>["Dharamsala, Distt. Kangra, H.P."], "pub_date"=>["2007"], "format"=>"Book", "title_display"=>"Ses yon", "material_type_display"=>["xii, 419 p."], "id"=>"2008308478", "placename_facet_field"=>["China", "Tibet", "India"], "subject_topic_facet"=>["Education and state", "Tibetans", "Tibetan language", "Teaching"], "language_facet"=>["Tibetan"], "geojson"=>["{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[104.195397,35.86166]},\"properties\":{\"placename\":\"China\"}}", "{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[91.117212,29.646923]},\"properties\":{\"placename\":\"Tibet\"}}", "{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[78.96288,20.593684]},\"properties\":{\"placename\":\"India\"}}"], "coordinates"=>["68.162386 6.7535159 97.395555 35.5044752", "104.195397 35.86166", "91.117212 29.646923", "20.593684,78.96288"], "score"=>0.0026767207 }]}
  end

  subject {BlacklightMaps::GeojsonExport.new(@controller, @action, @response.docs)}

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
      expect(subject.send(:search_mode)).to eq('placename_facet')
    end

    it "should return facet_mode" do
      expect(subject.send(:facet_mode)).to eq('geojson')
    end

    it "should return placename_property" do
      expect(subject.send(:placename_property)).to eq('placename')
    end

  end

  describe "build_feature_from_geojson" do

    it "should build a feature from well-formed geojson" do
      expect(subject.send(:build_feature_from_geojson, '{"type":"Feature","geometry":{"type":"Point","coordinates":[104.195397,35.86166]},"properties":{"placename":"China"}}')).to eq('{"type"=>"Feature", "geometry"=>{"type"=>"Point", "coordinates"=>[104.195397, 35.86166]}, "properties"=>{"placename"=>"China", "popup"=>"<h5 class=\"geo_facet_heading\">\n  China\n  \n</h5>\n<a href=\"/catalog?f%5Bplacename_facet_field%5D%5B%5D=China\">View items from this location</a>"}}')
    end

    it "should build a point feature from a bbox" do

    end

    describe "catalog#show view" do

      it "should build a bbox feature from a bbox" do

      end

    end


  end


=begin

  it "should return point feature with no properties" do
    expect(subject.send(:build_point_feature, 100, -50)).to eq({:type=>"Feature", :geometry=>{:type=>"Point", :coordinates=>[100.0, -50.0]}, :properties=>{}})
  end

  it "should return point feature with properties" do
    expect(subject.send(:build_point_feature, 100, -50, { name: 'Jane Smith' })[:properties]).to have_key(:name)
  end

  it "should build bbox correct features" do
    expect(subject.send(:build_bbox_features).length).to eq(1)
    expect(subject.send(:build_bbox_features)[0][:geometry][:type]).to eq('Point')
  end

  it "should render correct sidebar div" do
    expect(subject.send(:render_leaflet_sidebar_partial, @response.docs[0])).to include('href="/catalog/2008308478')
  end

  it "should render feature collection as json" do
    expect(subject.to_geojson).to include('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point"')
  end
=end

end
