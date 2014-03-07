require 'spec_helper'

describe "Map view", :js => true do
  before { visit catalog_index_path :q => 'tibet', :view => 'maps' }

  it "should display results in a map" do
    expect(page).to have_selector("#documents.map")
  end

  it "should contain map div" do
    expect(page).to have_selector("#map")
  end

  it "should contain leaflet-sidebar div" do
    expect(page).to have_selector("#leaflet-sidebar")
  end

  describe "Data attributes" do

    it "should have lat lng field" do
      expect(page).to have_selector("#map[data-latlngfield=geoloc]") 
    end

    it "maxzoom should be 8" do
      expect(page).to have_selector("#map[data-maxzoom='8']")
    end
 
    it "should have placename field" do
      expect(page).to have_selector("#map[data-placefield=subject_geo_facet]") 
    end

    it "should have title field" do
      expect(page).to have_selector("#map[data-titlefield=title_display]")
    end

    it "should have id field" do
      expect(page).to have_selector("#map[data-docid=id]")
    end

    it "should have doc path field" do
      expect(page).to have_selector("#map[data-docurl]")
    end

  end

  describe "Marker clusters" do
    
    it "should have marker cluster div" do
      expect(page).to have_selector("div.marker-cluster")
    end

    it "should only have one marker cluster" do
      expect(page).to have_selector('div.marker-cluster', count: 1)
    end

    it "should have 4 markers" do
      expect(find("div.marker-cluster")).to have_content(4)
    end

    describe "Click Marker cluster" do
      before { find("div.marker-cluster").click }
      
      it "should have three marker clusters" do
        expect(page).to have_selector('div.marker-cluster', count: 3)
      end

      describe "Click low level marker cluster" do
        before { find("div.marker-cluster[title='India']").click }

        it "should show sidebar with content" do
          expect(page).to have_content("yon")
        end

        describe "Navigate to catalog page" do
          before { click_link("es yon") }

          it "should show sidebar with content" do
            expect(page).to have_content("Dharamsala, Distt. Kangra, H.P.")
          end

      end

      end

    end

   
    #TODO more tests
  end

  describe "Sidebar" do

    #TODO more tests

  end
end