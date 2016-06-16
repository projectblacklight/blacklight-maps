# -*- encoding : utf-8 -*-
require 'spec_helper'

describe BlacklightMapsHelper do

  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:search_state) { Blacklight::SearchState.new({}, blacklight_config) }

  def create_response
    raw_response = eval(mock_query_response)
    Blacklight::Solr::Response.new(raw_response, raw_response['params'])
  end

  let(:r) { create_response }
  let(:geojson_hash) { { type: 'Feature', geometry: { type: 'Point', coordinates: [91.117212, 29.646923] }, properties: { placename: 'Tibet' } } }
  let(:coords) { [91.117212, 29.646923] }
  let(:bbox) { [78.3955448, 26.8548157, 99.116241, 36.4833345] }

  before :each do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
    CatalogController.blacklight_config = Blacklight::Configuration.new
    @request = ActionDispatch::TestRequest.new
    @catalog = CatalogController.new
    allow(helper).to receive_messages(blacklight_configuration_context: Blacklight::Configuration::Context.new(@catalog))
    allow(helper).to receive(:search_state).and_return(search_state)
    @catalog.request = @request
    @catalog.action_name = "index"
    helper.instance_variable_set(:@_controller, @catalog)
    @docs = r.aggregations[blacklight_config.view.maps.geojson_field].items
  end

  describe "blacklight_map_tag" do

    context "with default values" do
      subject { helper.blacklight_map_tag('blacklight-map') }
      it { should have_selector "div#blacklight-map" }
      it { should have_selector "div[data-maxzoom='#{blacklight_config.view.maps.maxzoom}']" }
      it { should have_selector "div[data-tileurl='#{blacklight_config.view.maps.tileurl}']" }
      it { should have_selector "div[data-mapattribution='#{blacklight_config.view.maps.mapattribution}']" }
    end

    context "with custom values" do
     subject { helper.blacklight_map_tag('blacklight-map', data: {maxzoom: 6, tileurl: 'http://example.com/', mapattribution: 'hello world' }) }
     it { should have_selector "div[data-maxzoom='6'][data-tileurl='http://example.com/'][data-mapattribution='hello world']" }
    end

    context "when a block is provided" do
      subject { helper.blacklight_map_tag('foo') { content_tag(:span, 'bar') } }
      it { should have_selector('div > span', text: 'bar') }
    end

  end

  describe "serialize_geojson" do

    it "should return geojson of documents" do
      expect(helper.serialize_geojson(@docs)).to include('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point"')
    end

  end

  describe "placename_value" do

    it "should return the placename value" do
      expect(helper.placename_value(geojson_hash)).to eq('Tibet')
    end

  end

  describe "link_to_bbox_search" do

    it "should create a spatial search link" do
      expect(helper.link_to_bbox_search(bbox)).to include('catalog?coordinates')
      expect(helper.link_to_bbox_search(bbox)).to include('spatial_search_type=bbox')
    end

    it "should include the default_document_index_view_type in the params" do
      expect(helper.link_to_bbox_search(bbox)).to include('view=list')
    end

  end

  describe "link_to_placename_field" do

    it "should create a link to the placename field" do
      expect(helper.link_to_placename_field('Tibet', blacklight_config.view.maps.placename_field)).to include("catalog?f%5B#{blacklight_config.view.maps.placename_field}%5D%5B%5D=Tibet")
    end

    it "should create a link to the placename field using the display value" do
      expect(helper.link_to_placename_field('Tibet', blacklight_config.view.maps.placename_field, 'foo')).to include('">foo</a>')
    end

    it "should include the default_document_index_view_type in the params" do
      expect(helper.link_to_placename_field('Tibet', blacklight_config.view.maps.placename_field)).to include('view=list')
    end

  end

  describe "link_to_point_search" do

    it "should create a link to a coordinate point" do
      expect(helper.link_to_point_search(coords)).to include('catalog?coordinates')
      expect(helper.link_to_point_search(coords)).to include('spatial_search_type=point')
    end

    it "should include the default_document_index_view_type in the params" do
      expect(helper.link_to_point_search(coords)).to include('view=list')
    end

  end

  describe "map_facet_field" do

    it "should return the correct facet field" do
      expect(helper.map_facet_field).to eq(blacklight_config.view.maps.geojson_field)
    end

  end

  describe "map_facet_values" do

    before do
      @response = r
    end

    it "should return an array of Blacklight::Solr::Response::Facets::FacetItem items" do
      expect(helper.map_facet_values.class).to eq(Array)
      expect(helper.map_facet_values.first.class).to eq(Blacklight::Solr::Response::Facets::FacetItem)
      expect(helper.map_facet_values.length).to eq(5)
    end

  end

  describe "render_placename_heading" do

    it "should return the placename heading" do
      expect(helper.render_placename_heading(geojson_hash)).to eq('Tibet')
    end

  end

  describe "render_index_mapview" do

    before do
      @response = r
    end

    it "should render the 'catalog/index_mapview' partial" do
      expect(helper.render_index_mapview).to include("$('#blacklight-index-map').blacklight_leaflet_map")
    end

  end

  describe "render_spatial_search_link" do

    it "should return link_to_bbox_search if bbox coordinates are passed" do
      expect(helper.render_spatial_search_link(bbox)).to include('spatial_search_type=bbox')
    end

    it "should return link_to_point_search if point coordinates are passed" do
      expect(helper.render_spatial_search_link(coords)).to include('spatial_search_type=point')
    end

  end

  def mock_query_response
    %({"responseHeader"=>{"status"=>0, "QTime"=>14, "params"=>{"q"=>"tibet", "spellcheck.q"=>"tibet", "qt"=>"search", "wt"=>"ruby", "rows"=>"10"}}, "response"=>{"numFound"=>2, "start"=>0, "maxScore"=>0.016135123, "docs"=>[{"published_display"=>["Dharamsala, H.P."], "author_display"=>"Thub-bstan-yar-ÃŠÂ¼phel, Rnam-grwa", "lc_callnum_display"=>["DS785 .T475 2005"], "pub_date"=>["2005"], "format"=>"Book", "material_type_display"=>["a-e, iv, ii, 407 p."], "title_display"=>"Bod gaÃ¡Â¹â€¦s can gyi rgyal rabs mdor bsdus dris lan brgya pa rab gsal Ã…â€ºel gyi me loÃ¡Â¹â€¦ Ã…Âºes bya ba bÃ…Âºugs so", "id"=>"2008308202", "subject_geo_facet"=>["Tibet"], "language_facet"=>["Tibetan"], "geojson"=>["{\\"type\\":\\"Feature\\",\\"geometry\\":{\\"type\\":\\"Point\\",\\"coordinates\\":[91.117212, 29.646923]},\\"properties\\":{\\"placename\\":\\"Tibet\\"}}", "{\\"type\\":\\"Feature\\",\\"geometry\\":{\\"type\\":\\"Polygon\\",\\"coordinates\\":[[[78.3955448, 26.8548157], [99.116241, 26.8548157], [99.116241, 36.4833345], [78.3955448, 36.4833345], [78.3955448, 26.8548157]]]},\\"bbox\\":[78.3955448,26.8548157,99.116241,36.4833345]}"], "coordinates"=>["91.117212 29.646923", "78.3955448 26.8548157 99.116241 36.4833345"], "score"=>0.016135123}, {"published_display"=>["Dharamsala, Distt. Kangra, H.P."], "pub_date"=>["2007"], "format"=>"Book", "title_display"=>"Ses yon", "material_type_display"=>["xii, 419 p."], "id"=>"2008308478", "subject_geo_facet"=>["China", "Tibet", "India"], "subject_topic_facet"=>["Education and state", "Tibetans", "Tibetan language", "Teaching"], "language_facet"=>["Tibetan"], "geojson"=>["{\\"type\\":\\"Feature\\",\\"geometry\\":{\\"type\\":\\"Point\\",\\"coordinates\\":[104.195397,35.86166]},\\"properties\\":{\\"placename\\":\\"China\\"}}", "{\\"type\\":\\"Feature\\",\\"geometry\\":{\\"type\\":\\"Point\\",\\"coordinates\\":[91.117212,29.646923]},\\"properties\\":{\\"placename\\":\\"Tibet\\"}}", "{\\"type\\":\\"Feature\\",\\"geometry\\":{\\"type\\":\\"Point\\",\\"coordinates\\":[78.96288,20.593684]},\\"properties\\":{\\"placename\\":\\"India\\"}}","{\\"type\\":\\"Feature\\",\\"geometry\\":{\\"type\\":\\"Polygon\\",\\"coordinates\\":[[[68.162386, 6.7535159], [97.395555, 6.7535159], [97.395555, 35.5044752], [68.162386, 35.5044752], [68.162386, 6.7535159]]]},\\"bbox\\":[68.162386,6.7535159,97.395555,35.5044752]}"], "coordinates"=>["68.162386 6.7535159 97.395555 35.5044752", "104.195397 35.86166", "91.117212 29.646923", "78.96288 20.593684"], "score"=>0.0026767207}]}, "facet_counts"=>{"facet_queries"=>{}, "facet_fields"=>{"format"=>["Book", 2], "lc_1letter_facet"=>["D - World History", 1], "lc_alpha_facet"=>["DS", 1], "lc_b4cutter_facet"=>["DS785", 1], "language_facet"=>["Tibetan", 2], "pub_date"=>["2005", 1, "2007", 1], "subject_era_facet"=>[], "subject_geo_facet"=>["China", 1, "India", 1, "Tibet", 1, "Tibet (China)", 1], "coordinates"=>["91.117212 29.646923", 2, "78.3955448 26.8548157 99.116241 36.4833345", 1, "68.162386 6.7535159 97.395555 35.5044752", 1, "104.195397 35.86166", 1, "78.96288 20.593684", 1], "geojson"=>["{\\"type\\":\\"Feature\\",\\"geometry\\":{\\"type\\":\\"Point\\",\\"coordinates\\":[91.117212, 29.646923]},\\"properties\\":{\\"placename\\":\\"Tibet\\"}}", 2, "{\\"type\\":\\"Feature\\",\\"geometry\\":{\\"type\\":\\"Polygon\\",\\"coordinates\\":[[[78.3955448, 26.8548157], [99.116241, 26.8548157], [99.116241, 36.4833345], [78.3955448, 36.4833345], [78.3955448, 26.8548157]]]},\\"bbox\\":[78.3955448,26.8548157,99.116241,36.4833345]}", 1, "{\\"type\\":\\"Feature\\",\\"geometry\\":{\\"type\\":\\"Point\\",\\"coordinates\\":[104.195397,35.86166]},\\"properties\\":{\\"placename\\":\\"China\\"}}", 1, "{\\"type\\":\\"Feature\\",\\"geometry\\":{\\"type\\":\\"Point\\",\\"coordinates\\":[78.96288,20.593684]},\\"properties\\":{\\"placename\\":\\"India\\"}}", 1, "{\\"type\\":\\"Feature\\",\\"geometry\\":{\\"type\\":\\"Polygon\\",\\"coordinates\\":[[[68.162386, 6.7535159], [97.395555, 6.7535159], [97.395555, 35.5044752], [68.162386, 35.5044752], [68.162386, 6.7535159]]]},\\"bbox\\":[68.162386,6.7535159,97.395555,35.5044752]}", 1], "subject_topic_facet"=>["Education and state", 1, "Teaching", 1, "Tibetan language", 1, "Tibetans", 1]}, "facet_dates"=>{}, "facet_ranges"=>{}}, "spellcheck"=>{"suggestions"=>["tibet", {"numFound"=>1, "startOffset"=>0, "endOffset"=>5, "origFreq"=>2, "suggestion"=>[{"word"=>"tibetan", "freq"=>6}]}, "correctlySpelled", true]}})
  end

end
