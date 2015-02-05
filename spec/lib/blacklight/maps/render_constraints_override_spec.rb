require 'spec_helper'

describe BlacklightMaps::RenderConstraintsOverride do

  class BlacklightMapsControllerTestClass < CatalogController
    attr_accessor :params
  end

  before(:each) do
    @fake_controller = BlacklightMapsControllerTestClass.new
    @fake_controller.extend(BlacklightMaps::RenderConstraintsOverride)
    @fake_controller.params = { coordinates: "35.86166,104.195397", spatial_search_type: "point" }
  end

  describe "testing for spatial parameters" do

    describe "has_spatial_parameters?" do

      it "should be true if coordinate params are present" do
        expect(@fake_controller.has_spatial_parameters?).to be true
      end

    end

    describe "has_search_parameters?" do

      it "should be true if coordinate params are present" do
        expect(@fake_controller.has_search_parameters?).to be true
      end

    end

  end

  describe "render spatial constraints" do

    before do
      @test_params = @fake_controller.params
    end

    describe "query_has_constraints?" do

      it "should be true if there are coordinate params" do
        expect(@fake_controller.query_has_constraints?).to be true
      end

    end

    describe "spatial_constraint_label" do

      it "should return the point label" do
        expect(@fake_controller.spatial_constraint_label(@test_params)).to eq(I18n.t('blacklight.search.filters.coordinates.point'))
      end

      it "should return the bbox label" do
        @test_params = { spatial_search_type: "bbox" }
        expect(@fake_controller.spatial_constraint_label(@test_params)).to eq(I18n.t('blacklight.search.filters.coordinates.bbox'))
      end

    end

    describe "render_spatial_query" do

      before :each do
        # have to create a request or call to 'url _for' returns an error
        @fake_controller.request = ActionDispatch::Request.new(params:{controller: 'catalog', action: 'index'})
        @fake_controller.request.path_parameters[:controller] = 'catalog'
      end

      # TODO: can't get these specs to pass, getting error:
      # NoMethodError: undefined method `render_constraint_element'

      it "should render the coordinates" #do
        #expect(@fake_controller.render_spatial_query(@test_params)).to have_content(@fake_controller.params[:coordinates])
      #end

      it "should remove spatial params in the 'remove' link" #do
        #expect(@fake_controller.render_spatial_query(@test_params)).to_not have_content("spatial_search_type")
      #end

    end

    describe "render_search_to_s_coord" do

      it "should return render_search_to_s_element when coordinates are present" do
        expect(@fake_controller).to receive(:render_search_to_s_element)
        expect(@fake_controller).to receive(:render_filter_value)
        @fake_controller.render_search_to_s_coord(@test_params)
      end

    end

  end

end