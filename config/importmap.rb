# frozen_string_literal: true

pin_all_from File.expand_path('../app/javascript/blacklight-maps', __dir__), under: 'blacklight-maps'

pin 'leaflet', to: 'https://cdn.jsdelivr.net/npm/leaflet@1.9.4/+esm'
pin 'leaflet.markercluster', to: 'https://cdn.jsdelivr.net/npm/leaflet.markercluster@1.5.3/+esm'
