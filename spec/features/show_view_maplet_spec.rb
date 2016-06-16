require 'spec_helper'

describe "catalog#show view", js: true do

  before :each do
    CatalogController.blacklight_config = Blacklight::Configuration.new
    CatalogController.configure_blacklight do |config|
      # add maplet to show view partials
      config.show.partials << :show_maplet
    end
  end

  describe "item with point feature" do

    before :each do
      visit solr_document_path("00314247")
    end

    it "should display the maplet" do
      expect(page).to have_selector("#blacklight-show-map-container")
    end

    it "should have a single marker icon" do
      expect(page).to have_selector(".leaflet-marker-icon", count: 1)
    end

    describe "click marker icon" do

      before { find(".leaflet-marker-icon").click }

      it "should show a popup with correct content" do
        expect(page).to have_selector("div.leaflet-popup-content-wrapper")
        expect(page).to have_content("Japan")
      end

    end

  end

  describe "item with point and bbox features" do

    before :each do
      visit solr_document_path("2008308175")
    end

    it "should show the correct mapped item count" do
      expect(page).to have_selector(".mapped-count .badge", text: "2")
    end

    it "should show a bounding box and a point marker" do
      expect(page).to have_selector(".leaflet-overlay-pane path.leaflet-clickable")
      expect(page).to have_selector(".leaflet-marker-icon")
    end

    describe "click bbox path" do

      before do
        0.upto(4) { find("a.leaflet-control-zoom-in").click } #so bbox not covered by point
        find(".leaflet-overlay-pane svg").click
      end

      it "should show a popup with correct content" do
        expect(page).to have_selector("div.leaflet-popup-content-wrapper")
        expect(page).to have_content("[68.162386, 6.7535159, 97.395555, 35.5044752]")
      end

    end

  end

  describe "item with bbox feature" do

    before :each do
      CatalogController.configure_blacklight do |config|
        # set maxzoom so we can test whether initial zoom is correct
        config.view.maps.maxzoom = 8
      end
      visit solr_document_path("2009373514")
    end

    it "should display a bounding box" do
      expect(page).to have_selector(".leaflet-overlay-pane path.leaflet-clickable")
    end

    it "should zoom to the correct map bounds" do
      # if initial zoom >= maxzoom, zoom-in control will be disabled
      expect(page).to have_selector(".leaflet-control-zoom-in.leaflet-disabled")
    end

  end

end