import LeafletController from 'blacklight-maps/controllers/leaflet_controller'

export default class {
  connect() {
    if (typeof Stimulus === "undefined") {
      console.error("Couldn't find Stimulus. Check installation instructions at https://github.com/hotwired/stimulus-rails.")
      return
    }
    Stimulus.register('blacklight-maps-leaflet', LeafletController)
  }
}
