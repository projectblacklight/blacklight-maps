# Blacklight::Maps

[![Build Status](https://travis-ci.org/sul-dlss/blacklight-maps.png?branch=master)](https://travis-ci.org/sul-dlss/blacklight-maps)

Provides a map view for Blacklight search results.

![Screen shot](docs/map-view.png)
![Screen shot](docs/map-sidebar.png)

## Installation

Add this line to your application's Gemfile:

    gem 'blacklight-maps'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blacklight-maps

## Usage

Blacklight-Maps adds a map view capability for a results set that contains geospatial coordinates (latitude/longitude).

Blacklight-Maps requires that your SOLR index includes lat/lon coordinates located in a field that relates to a placename.  For example: 

A document could have the following placenames:
```  
  subject_geo_facet:
    - China
    - Tibet
    - India
```
These placenames are already geocoded and given as an array in the same order:
```    
  geoloc:
    - "[35.86166, 104.195397]"
    - "[29.646923, 91.117212]"
    - "[20.593684, 78.96288]"
```

### Configuration

#### Required
Blacklight-Maps expects you to provide several things:

- a field to map the placename array (`subject_geo_facet` in the example above)
- a field to map to the latitude/longitude array (`geoloc` in the example above)

#### Optional

- a field that the document thumbnail url resides


All of these options can easily be configured in `CatalogController.rb` in the `config` block.

```
...
  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = { 
      :qt   => 'search',
      :rows => 10,
      :fl   => '*'
    }

    config.view.maps.placename_field = "subject_geographic_ssim"
    config.view.maps.thumbnail_field = "thumbnail_url_ssm"
    config.view.maps.lat_lng_field = "subject_geographic_coords"
...

```


## Contributing

1. Fork it ( http://github.com/<my-github-username>/blacklight-maps/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
