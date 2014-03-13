# Helper methods used for Blacklight Maps
module BlacklightMapsHelper
  def show_map_div
    data_attributes = {
        maxzoom: blacklight_config.view.maps.maxzoom,
        tileurl: blacklight_config.view.maps.tileurl

      }

    content_tag(:div, '',
                id: 'blacklight-map',
                data: data_attributes
    )
  end

  def serialize_geojson
    geojson_docs = { type: 'FeatureCollection', features: [] }
    @response.docs.each_with_index do |doc, counter|
      if doc[blacklight_config.view.maps.placename_coord_field]
        doc[blacklight_config.view.maps.placename_coord_field].each do |loc|
          values = loc.split(blacklight_config.view.maps.placename_coord_delimeter)
          feature = { type: 'Feature',
                      geometry: {
                        type: 'Point',
                        coordinates: [values[2].to_f, values[1].to_f] },
                      properties: {
                        placename: values[0],
                        html: render_leaflet_sidebar_partial(doc) } }
          geojson_docs[:features].push feature
        end
      end
    end

    geojson_docs.to_json
  end

  def render_leaflet_sidebar_partial(doc)
    render partial: 'catalog/index_maps', locals: { document: SolrDocument.new(doc) }
  end
end
