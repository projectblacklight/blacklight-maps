require 'spec_helper'

describe "BlacklightMaps::Geometry::BoundingBox" do

  let(:bbox) { BlacklightMaps::Geometry::BoundingBox.from_lon_lat_string('-100 -50 100 50') }
  let(:bbox_california) { BlacklightMaps::Geometry::BoundingBox.from_lon_lat_string('-124.4096196 32.5342321 -114.131211 42.0095169') }

  it "should instantiate Geometry::BoundingBox" do
    expect(bbox.class).to eq(::BlacklightMaps::Geometry::BoundingBox)
  end

  it "should return center of simple bounding box" do
    expect(bbox.find_center).to eq([0.0, 0.0])
  end

  it "should return center of California bounding box" do
    expect(bbox_california.find_center).to eq([-119.2704153, 37.271874499999996])
  end
end
