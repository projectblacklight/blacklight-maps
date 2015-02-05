require 'spec_helper'

describe CatalogController do

  render_views

  describe "GET 'map'" do

    before { get :map }

    it "should respond to the #map action" do
      response.should be_success
      assigns(:document_list).should_not be_nil
    end

    it "should render the '/map' page" do
      response.body.should have_selector("body.blacklight-catalog-map")
    end

  end

end