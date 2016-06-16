class SearchHistoryController < ApplicationController
  include Blacklight::SearchHistory

  helper BlacklightMaps::RenderConstraintsOverride
end