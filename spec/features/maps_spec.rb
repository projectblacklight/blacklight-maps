require 'spec_helper'

describe "Map View", js: true do

  before :each do
    CatalogController.blacklight_config = Blacklight::Configuration.new
  end

  describe "catalog#index and catalog#map views" do

    before :each do
      CatalogController.configure_blacklight do |config|
        # facet for blacklight-maps catalog#index map view
        config.add_facet_field 'geojson', :limit => -2, :label => 'GeoJSON', :show => false
        config.add_facet_fields_to_solr_request!
      end
    end

    describe "catalog#index map view" do

      before {
        visit catalog_index_path :q => 'korea', :view => 'maps'
        #print page.html # debugging
      }

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

        # placeholder spec: #sortAndPerPage > .view-type > .view-type-group should show
        # active map icon. however, this spec doesn't work because
        # Blacklight::ConfigurationHelperBehavior#has_alternative_views? returns false,
        # so catalog/_view_type_group partial renders no content
        # can't figure out why
        it "should show the map view icon"
        #expect(page).to have_selector(".view-type-maps.active")

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

        before { find(".marker-cluster:first-child").click }

        it "should show a popup with correct content" do
          expect(page).to have_selector("div.leaflet-popup-content-wrapper")
          expect(page).to have_content("Seoul (Korea)")
        end

        describe "click search link" do

          before { find("div.leaflet-popup-content a").click }

          it "should run a new search" do
            expect(page).to have_selector(".constraint-value .filterValue", text: "Seoul (Korea)")
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
          end

        end

      end

    end

  end





=begin
  describe "using bounding box" do
    before do
      CatalogController.blacklight_config = Blacklight::Configuration.new
      CatalogController.configure_blacklight do |config|
        config.view.maps.type = 'bbox'
        config.view.maps.bbox_field = 'place_bbox'
      end
    end

    before { visit catalog_index_path :q => 'korea', :view => 'maps' }

    it "should have 4 markers" do
      expect(find("div.marker-cluster")).to have_content(4)
    end

    it "should display number mapped" do
      expect(page).to have_content('4 mapped')
    end

    describe "click marker cluster" do
      before { find("div.marker-cluster").click }

      it "should split into 2 markers" do
        expect(page).to have_selector('div.marker-cluster', count: 2)
      end
    end
  end
=end
end
