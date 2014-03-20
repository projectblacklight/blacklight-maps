module BlacklightMaps

  # Parent class of geospatial objects used in BlacklightMaps
  class Geometry

    # This class contains Bounding Box objects and methods for interacting with
    # them.
    class BoundingBox

      # points is an array containing longitude and latitude values which
      # relate to the southwest and northeast points of a bounding box
      # [west, south, east, north] ([swlng, swlat, nelng, nelat]).
      def initialize(points)
        @west = points[0].to_f
        @south = points[1].to_f
        @east = points[2].to_f
        @north = points[3].to_f
      end

      # Returns an array [lng, lat] which is the centerpoint of a BoundingBox.
      def find_center
        center = []
        center[0] = (@west + @east) / 2
        center[1] = (@south + @north) / 2
        center
      end

      # Creates a new bounding box from from a string of points
      # "-100 -50 100 50" (south west north east)
      def self.from_lon_lat_string(points)
        new(points.split(' '))
      end
    end
  end
end
