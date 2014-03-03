require 'spec_helper'

describe "Map view" do
  before { visit catalog_index_path :q => 'medicine', :view => 'map' }

  it "should display results in a map" do
    expect(page).to have_selector("#documents.map")
  end
end