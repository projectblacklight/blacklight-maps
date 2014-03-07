module BlacklightMapsHelper
    
    def show_map_div
      data_attributes = {:latlngfield => blacklight_config.view.maps.lat_lng_field.to_s,
          :maxzoom => 8, :titlefield => blacklight_config.index.title_field,
          :placefield => blacklight_config.view.maps.placename_field, 
          :docurl => doc_url_path,
          :docid => SolrDocument.unique_key.to_s
        }

      if has_thumbnail_field_defined?
        data_attributes[:thumbfield] = blacklight_config.view.maps.thumbnail_field
      end

      content_tag(:div, "", :id => "map",
        :data => data_attributes
      )
    end

    def has_thumbnail_field_defined?
      blacklight_config.view.maps.thumbnail_field.present?
    end

    def doc_url_path
      path = url_for_document(SolrDocument).to_s.gsub("SolrDocument", "")
      if path.length < 1
        path = '/catalog/'
      end
      return path
    end

    def send_needed_map_fields
      returned_fields = [SolrDocument.unique_key, blacklight_config.view.maps.lat_lng_field,
        blacklight_config.index.title_field, blacklight_config.view.maps.placename_field]
      if has_thumbnail_field_defined?
        returned_fields.push blacklight_config.view.maps.thumbnail_field
      end  
      returned_docs = []
      @response.docs.each do |doc|
        returned_docs.push doc.select {|k,v| returned_fields.include?(k)}
      end
      return returned_docs.to_json
    end  
end