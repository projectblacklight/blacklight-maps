require 'spec_helper'

describe "BlacklightMaps::GeojsonExport" do

  class BlacklightMaps::GeojsonExport
    public :blacklight_maps_config, :type, :placename_coord_field, :placename_coord_delimiter, :bbox_field, :build_point_feature, :build_bbox_features, :render_leaflet_sidebar_partial
  end

  before do
    CatalogController.blacklight_config = Blacklight::Configuration.new
    CatalogController.configure_blacklight do |config|
      config.view.maps.type = 'placename_coord'

      # These fields also need to be added for some reason for the tests to pass
      # Link in list is not being generated correctly if not passed
      config.index.title_field = 'title_display'
    end
    @controller = CatalogController.new
    @request = ActionDispatch::TestRequest.new
    @controller.request = @request
    @response = ActionDispatch::TestResponse.new
    @response.stub(:docs) {[{ "published_display"=>["Dharamsala, Distt. Kangra, H.P."], "pub_date"=>["2007"], "format"=>"Book", "title_display"=>"Ses yon", "material_type_display"=>["xii, 419 p."], "id"=>"2008308478", "subject_geo_facet"=>["China", "Tibet", "India"], "subject_topic_facet"=>["Education and state", "Tibetans", "Tibetan language", "Teaching"], "language_facet"=>["Tibetan"], "placename_coords"=>["China-|-35.86166-|-104.195397", "Tibet-|-29.646923-|-91.117212", "India-|-20.593684-|-78.96288"], "place_bbox"=>"68.162386 6.7535159 97.395555 35.5044752", "score"=>0.0026767207 }]}
  end

  subject {BlacklightMaps::GeojsonExport.new(@controller, @response.docs)}

  it "should instantiate GeojsonExport" do
    expect(subject.class).to eq(::BlacklightMaps::GeojsonExport)
  end

  it "should return maps config" do
    expect(subject.blacklight_maps_config.class).to eq(::Blacklight::Configuration::ViewConfig)
  end

  it "should return type" do
    expect(subject.type).to eq('placename_coord')
  end

  it "should return placename field" do
    expect(subject.placename_coord_field).to eq('placename_coords')
  end

  it "should return placename delimiter" do
    expect(subject.placename_coord_delimiter).to eq('-|-')
  end

  it "should return bbox field" do
    expect(subject.bbox_field).to eq('place_bbox')
  end

  it "should return point feature with no properties" do
    expect(subject.build_point_feature(100, -50)).to eq({:type=>"Feature", :geometry=>{:type=>"Point", :coordinates=>[100.0, -50.0]}, :properties=>{}})
  end

  it "should return point feature with properties" do
    expect(subject.build_point_feature(100, -50, { name: 'Jane Smith' })[:properties]).to have_key(:name)
  end

  it "should build bbox correct features" do
    expect(subject.build_bbox_features.length).to eq(1)
    expect(subject.build_bbox_features[0][:geometry][:type]).to eq('Point')
  end

  it "should render correct sidebar div" do
    expect(subject.render_leaflet_sidebar_partial(@response.docs[0])).to include('href="/catalog/2008308478">')
  end

  it "should render feature collection as json" do
    expect(subject.to_geojson).to include('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point"')
  end


end
