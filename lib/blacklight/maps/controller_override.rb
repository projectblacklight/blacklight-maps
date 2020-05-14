module BlacklightMaps
  module ControllerOverride
    extend ActiveSupport::Concern

    included do
      self.send(:include, BlacklightMaps::RenderConstraintsOverride)
      self.send(:helper, BlacklightMaps::RenderConstraintsOverride)
    end

    def map
      (@response, @document_list) = search_results(params)
      params[:view] = 'maps'
      respond_to do |format|
        format.html
      end
    end
  end
end
