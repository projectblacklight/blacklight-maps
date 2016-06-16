class SavedSearchesController < ApplicationController
  include Blacklight::SavedSearches

  helper BlacklightMaps::RenderConstraintsOverride
end