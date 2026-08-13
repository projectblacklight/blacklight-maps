# frozen_string_literal: true

module BlacklightMaps
  class SpatialItemPresenter < Blacklight::FacetItemPresenter
    # Show the spatial search type ("Bounding Box" or "Coordinates") as the field label
    def field_label
      facet_item.label
    end

    # Show the actual coordinate string as the constraint value
    def constraint_label
      facet_item.value
    end
  end
end
