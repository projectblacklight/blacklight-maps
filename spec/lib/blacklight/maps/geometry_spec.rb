# frozen_string_literal: true

require 'spec_helper'

describe BlacklightMaps::Geometry do
  describe BlacklightMaps::Geometry::BoundingBox do
    let(:bbox) { described_class.from_lon_lat_string('-100 -50 100 50') }
    let(:bbox_california) { described_class.from_wkt_envelope('ENVELOPE(-124, -114, 42, 32)') }
    let(:bbox_dateline) { described_class.from_lon_lat_string('165 30 -172 -20') }

    it 'instantiates Geometry::BoundingBox' do
      expect(bbox.class).to eq(described_class)
    end

    describe '#find_center' do
      it 'returns center of simple bounding box' do
        expect(bbox.find_center).to eq([0.0, 0.0])
      end
    end

    describe '#to_a' do
      it 'returns the coordinates as an array' do
        expect(bbox.to_a).to eq([-100, -50, 100, 50])
      end
    end

    describe '#geojson_geometry_array' do
      it 'returns the coordinates as a multi dimensional array' do
        expect(bbox.geojson_geometry_array).to eq(
          [[[-100, -50], [100, -50], [100, 50], [-100, 50], [-100, -50]]]
        )
      end
    end

    it 'returns center of California bounding box' do
      expect(bbox_california.find_center).to eq([-119.0, 37.0])
    end

    it 'returns correct dateline bounding box' do
      expect(bbox_dateline.find_center).to eq([-183.5, 5])
    end
  end

  describe BlacklightMaps::Geometry::Point do
    let(:point) { described_class.from_lat_lon_string('20,120') }
    let(:unparseable_point) { described_class.from_lat_lon_string('35.86166,-184.195397') }

    it 'instantiates Geometry::Point' do
      expect(point.class).to eq(described_class)
    end

    it 'returns a Solr-parseable coordinate if @long is > 180 or < -180' do
      expect(unparseable_point.normalize_for_search).to eq([175.804603, 35.86166])
    end
  end

  it "should return 2d array of latitude longitude" do
    expect(bbox_dateline.to_latlng).to eq([[30, 165], [-20, -172]])
  end
end
