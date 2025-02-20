# frozen_string_literal: true

module BlacklightMaps
  # Parent class of geospatial objects used in BlacklightMaps
  class Geometry
    # This class contains Bounding Box objects and methods for interacting with
    # them.
    class BoundingBox
      # points is an array containing longitude and latitude values which
      # relate to the southwest and northeast points of a bounding box
      # [west, south, east, north] ([minX, minY, maxX, maxY]).
      def initialize(points)
        @west = points[0].to_f
        @south = points[1].to_f
        @east = points[2].to_f
        @north = points[3].to_f
      end

      def geojson_geometry_array
        [
          [
            [@west, @south],
            [@east, @south],
            [@east, @north],
            [@west, @north],
            [@west, @south]
          ]
        ]
      end

      # Returns an array [lng, lat] which is the centerpoint of a BoundingBox.
      def find_center
        center = []
        center[0] = (@west + @east) / 2
        center[1] = (@south + @north) / 2
        center[0] -= 180 if @west > @east # handle bboxes that cross the dateline
        center
      end

      # Creates a new bounding box from from a string of points
      # "-100 -50 100 50" (south west north east)
      def self.from_lon_lat_string(points)
        new(points.split(' '))
      end

      # Creates a new bounding box from from a Solr WKT Envelope string
      # "ENVELOPE(34.26, 35.89, 33.33, 29.47)" (minX, maxX, maxY, minY)
      def self.from_wkt_envelope(envelope)
        coords = envelope.gsub(/[[A-Z]()]/, '')&.split(', ')
        new([coords[0], coords[3], coords[1], coords[2]])
      end

      def to_a
        [@west, @south, @east, @north]
      end
    end

    # This class contains Point objects and methods for working with them
    class Point
      # points is an array corresponding to the longitude and latitude values
      # [long, lat]
      def initialize(points)
        @long = points[0].to_f
        @lat = points[1].to_f
      end

      # returns a string that can be used as the value of solr_parameters[:pt]
      # normalizes any long values >180 or <-180
      def normalize_for_search
        @long -= 360 if @long > 180
        @long += 360 if @long < -180
        [@long, @lat]
      end

      # Creates a new point from from a coordinate string
      # "-50,100" (lat,long)
      def self.from_lat_lon_string(points)
        new(points.split(',').reverse)
      end
    end
  end
end
