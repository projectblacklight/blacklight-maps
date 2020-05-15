# frozen_string_literal: true

require 'spec_helper'

describe BlacklightMaps::Geometry do

  describe "BlacklightMaps::Geometry::BoundingBox" do

    let(:bbox) { BlacklightMaps::Geometry::BoundingBox.from_lon_lat_string('-100 -50 100 50') }
    let(:bbox_california) { BlacklightMaps::Geometry::BoundingBox.from_lon_lat_string('-124.4096196 32.5342321 -114.131211 42.0095169') }
    let(:bbox_dateline) {BlacklightMaps::Geometry::BoundingBox.from_lon_lat_string('165 30 -172 -20') }

    it "should instantiate Geometry::BoundingBox" do
      expect(bbox.class).to eq(::BlacklightMaps::Geometry::BoundingBox)
    end

    it "should return center of simple bounding box" do
      expect(bbox.find_center).to eq([0.0, 0.0])
    end

    it "should return center of California bounding box" do
      expect(bbox_california.find_center).to eq([-119.2704153, 37.271874499999996])
    end

    it "should return correct dateline bounding box" do
      expect(bbox_dateline.find_center).to eq([-183.5, 5])
    end
  end

  describe "BlacklightMaps::Geometry::Point" do

    let(:point) { BlacklightMaps::Geometry::Point.from_lat_lon_string('20,120') }
    let(:unparseable_point) { BlacklightMaps::Geometry::Point.from_lat_lon_string('35.86166,-184.195397') }

    it "should instantiate Geometry::Point" do
      expect(point.class).to eq(::BlacklightMaps::Geometry::Point)
    end

    it "should return a Solr-parseable coordinate if @long is > 180 or < -180" do
      expect(unparseable_point.normalize_for_search).to eq([175.804603,35.86166])
    end

  end

end
