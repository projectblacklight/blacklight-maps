require 'spec_helper'

describe CatalogController do

  render_views

  describe "GET 'map'" do

    before { get :map }

    it "should respond to the #map action" do
      expect(response).to be_success
      expect(assigns(:document_list)).to_not be_nil
    end

    it "should render the '/map' page" do
      expect(response.body).to have_css 'body.blacklight-catalog-map'
    end

  end

end