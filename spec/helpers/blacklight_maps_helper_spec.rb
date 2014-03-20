require 'spec_helper'

describe BlacklightMapsHelper do
  include ERB::Util

  let(:blacklight_config) { Blacklight::Configuration.new }
 
  describe "#blacklight_map_tag" do
    before do
      helper.stub(blacklight_config: blacklight_config)
    end

    context "with default values" do
      subject { helper.blacklight_map_tag('blacklight-map') }
      it { should have_selector "div#blacklight-map" }
      it { should have_selector "div[data-maxzoom='8'][data-tileurl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png']" }
    end

    context "with custom values" do
      subject { helper.blacklight_map_tag('blacklight-map', data: {maxzoom: 6, tileurl: 'http://example.com/' }) }
      it { should have_selector "div[data-maxzoom='6'][data-tileurl='http://example.com/']" }
    end

    context "when a block is provided" do
      subject { helper.blacklight_map_tag('foo') { content_tag(:span, 'bar') } }
      it { should have_selector('div > span', text: 'bar') }
    end


  end

  # TODO Test geoJSON serialization
 
  

end
