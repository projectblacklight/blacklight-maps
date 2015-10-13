require 'spec_helper'

describe "Map View", js: true do

  before :each do
    CatalogController.blacklight_config = Blacklight::Configuration.new
  end

  describe "catalog#index and catalog#map views" do

    describe "catalog#index map view" do

      before :each do
        CatalogController.configure_blacklight do |config|
          # use geojson facet for blacklight-maps catalog#index map view specs
          config.add_facet_field 'geojson', :limit => -2, :label => 'GeoJSON', :show => false
          config.add_facet_fields_to_solr_request!
        end
        visit catalog_index_path :q => 'korea', :view => 'maps'
      end

      it "should display map elements" do
        expect(page).to have_selector("#documents.map")
        expect(page).to have_selector("#blacklight-index-map")
      end

      it "should display tile layer attribution" do
        expect(find("div.leaflet-control-container")).to have_content('OpenStreetMap contributors, CC-BY-SA')
      end

      describe "#sortAndPerPage" do

        it "should show the mapped item count" do
          expect(page).to have_selector(".mapped-count .badge", text: "4")
        end

        it "should show the mapped item caveat" do
          expect(page).to have_selector(".mapped-caveat")
        end

        # TODO: placeholder spec: #sortAndPerPage > .view-type > .view-type-group
        # should show active map icon. however, this spec doesn't work because
        # Blacklight::ConfigurationHelperBehavior#has_alternative_views? returns false,
        # so catalog/_view_type_group partial renders no content, can't figure out why
        it "should show the map view icon" #do
          #expect(page).to have_selector(".view-type-maps.active")
        #end

      end

      describe "data attributes" do

        it "maxzoom should be from config" do
          expect(page).to have_selector("#blacklight-index-map[data-maxzoom='#{CatalogController.blacklight_config.view.maps.maxzoom}']")
        end

        it "tileurl should be from config" do
          expect(page).to have_selector("#blacklight-index-map[data-tileurl='#{CatalogController.blacklight_config.view.maps.tileurl}']")
        end

      end

      describe "marker clusters" do

        before {
          0.upto(2) { find("a.leaflet-control-zoom-out").click } # zoom out to create cluster
        }

        it "should have marker cluster div" do
          expect(page).to have_selector("div.marker-cluster")
        end

        it "should only have one marker cluster" do
          expect(page).to have_selector("div.marker-cluster", count: 1)
        end

        it "should show the result count" do
          expect(find("div.marker-cluster")).to have_content(4)
        end

        describe "click marker cluster" do

          before { find("div.marker-cluster").click }

          it "should split into two marker clusters" do
            expect(page).to have_selector("div.marker-cluster", count: 2)
          end

        end

      end

      describe "marker popups" do
        before do
          find('.marker-cluster', text: '1', match: :first).click
        end

        it "should show a popup with correct content" do
          expect(page).to have_selector("div.leaflet-popup-content-wrapper")
          expect(page).to have_content("Seoul (Korea)")
        end

        describe "click search link" do

          before { find("div.leaflet-popup-content a").click }

          it "should run a new search" do
            expect(page).to have_selector(".constraint-value .filterValue", text: "Seoul (Korea)")
          end

          it "should use the default view type" do
            expect(current_url).to include("view=list")
          end

        end

      end

      describe "map search control" do

        it "should have a search control" do
          expect(page).to have_selector(".leaflet-control .search-control")
        end

        describe "search control hover" do

          before { find(".search-control").hover }

          it "should add a border to the map" do
            expect(page).to have_selector(".leaflet-overlay-pane path")
          end

        end

        describe "search control click" do

          before { find(".search-control").click }

          it "should run a new search" do
            expect(page).to have_selector(".constraint.coordinates")
            expect(current_url).to include("view=list")
          end

        end

      end

    end

    describe "catalog#map view" do

      before :each do
        CatalogController.configure_blacklight do |config|
          # use coordinates_facet facet for blacklight-maps catalog#map view specs
          config.view.maps.facet_mode = 'coordinates'
          config.view.maps.coordinates_facet_field = 'coordinates_facet'
          config.add_facet_field 'coordinates_facet', :limit => -2, :label => 'Coordinates', :show => false
          config.add_facet_fields_to_solr_request!
        end
        visit map_path
        #print page.html # debugging
      end

      it "should display map elements" do
        expect(page).to have_selector("#documents.map")
        expect(page).to have_selector("#blacklight-index-map")
      end

      it "should display some markers" do
        expect(page).to have_selector("div.marker-cluster")
      end

      describe "marker popups" do

        before :each do
          0.upto(1) { find("a.leaflet-control-zoom-in").click } # zoom in
          find(".marker-cluster:first-child").click
        end

        it "should show a popup with correct content" do
          expect(page).to have_selector("div.leaflet-popup-content-wrapper")
          expect(page).to have_content("[35.86166, 104.195397]")
        end

        describe "click search link" do

          before { find("div.leaflet-popup-content a").click }

          it "should run a new search" do
            expect(page).to have_selector(".constraint-value .filterValue", text: "35.86166,104.195397")
            expect(current_url).to include("view=list")
          end

        end

      end

    end

  end

end
