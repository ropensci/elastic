elastic
=======



[![Build Status](https://api.travis-ci.org/ropensci/elastic.png)](https://travis-ci.org/ropensci/elastic)
[![Build status](https://ci.appveyor.com/api/projects/status/swmmw758mf1heoj2/branch/master)](https://ci.appveyor.com/project/sckott/elastic/branch/master)

**A general purpose R interface to [Elasticsearch](http://elasticsearch.org)**


## Elasticsearch info

+ [Elasticsearch home page](http://elasticsearch.org)
+ [API docs](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/index.html)

## Notes

* This client is being developed under `v1.4` of Elasticsearch.
* It is early days for `elastic`, so help us by submitting bug reports and feature requests on the issue tracker.
* BEWARE: the API for this pkg is still changing...
* To avoid potential conflicts with other R packges, this package adds `es_` as a prefix to every function.

## Quick start

### Install elastic


```r
install.packages("devtools")
devtools::install_github("ropensci/elastic")
```


```r
library('elastic')
```

### Install Elasticsearch 

* [Elasticsearch installation help](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/_installation.html)

__on OSX__

+ Download zip or tar file from Elasticsearch [see here for download](http://www.elasticsearch.org/overview/elkdownloads/), e.g., `curl -L -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.1.tar.gz`
+ Unzip it: `untar elasticsearch-1.4.1.tar.gz`
+ Move it: `sudo mv /path/to/elasticsearch-1.4.1 /usr/local` (replace version with your version)
+ Navigate to /usr/local: `cd /usr/local`
+ Add shortcut: `sudo ln -s elasticsearch-1.4.1 elasticsearch` (replace version with your verioon)

You can also install via Homebrew: `brew install elasticsearch`

### Start Elasticsearch

* Navigate to elasticsearch: `cd /usr/local/elasticsearch`
* Start elasticsearch: `bin/elasticsearch`

I create a little bash shortcut called `es` that does both of the above commands in one step (`cd /usr/local/elasticsearch && bin/elasticsearch`).

### Get some data

Elasticsearch has a bulk load API to load data in fast. The format is pretty weird though. It's sort of JSON, but would pass no JSON linter. I include a few data sets in `elastic` so it's easy to get up and running, and so when you run examples in this package they'll actually run the same way (hopefully).

I have prepare a non-exported function useful for preparing the weird format that Elasticsearch wants for bulk data loads, that is somewhat specific to PLOS data (See below), but you could modify for your purposes. See `make_bulk_plos()` and `make_bulk_gbif()` [here](https://github.com/ropensci/elastic/blob/master/R/es_bulk.r). 

#### Shakespeare data

Elasticsearch provides some data on Shakespeare plays. I've provided a subset of this data in this package. Get the path for the file specific to your machine:


```r
shakespeare <- system.file("examples", "shakespeare_data.json", package = "elastic")
```

Then load the data into Elasticsearch:


```r
es_bulk(shakespeare)
```

If you need some big data to play with, the shakespeare dataset is a good one to start with. You can get the whole thing and pop it into Elasticsearch (beware, may take up to 10 minutes or so.):

```sh
curl -XGET http://www.elasticsearch.org/guide/en/kibana/current/snippets/shakespeare.json > shakespeare.json
curl -XPUT localhost:9200/_bulk --data-binary @shakespeare.json
```

#### Public Library of Science (PLOS) data

A dataset inluded in the `elastic` package is metadata for PLOS scholarly articles. Get the file path, then load:


```r
plosdat <- system.file("examples", "plos_data.json", package = "elastic")
es_bulk(plosdat)
```

#### Global Biodiversity Information Facility (GBIF) data

A dataset inluded in the `elastic` package is data for GBIF species occurrence records. Get the file path, then load:


```r
gbifdat <- system.file("examples", "gbif_data.json", package = "elastic")
es_bulk(gbifdat)
```

### Initialization

The function `es_connect` is used before doing anything else to set the connection details to your remote or local elasticsearch store. The details created by `es_connect` are written to your options for the current session, and are used by `elastic` functions.


```r
es_connect()
#> uri:       http://127.0.0.1 
#> port:      9200 
#> username:  NULL 
#> password:  NULL 
#> api key:   NULL 
#> elasticsearch details:   
#>       status:                  200 
#>       name:                    Melody Guthrie 
#>       Elasticsearch version:   1.4.0 
#>       ES version timestamp:    2014-11-05T14:26:12Z 
#>       lucene version:          4.10.2
```

### Search


```r
es_search(index="plos", size=1)
#> $took
#> [1] 2
#> 
#> $timed_out
#> [1] FALSE
#> 
#> $`_shards`
#> $`_shards`$total
#> [1] 5
#> 
#> $`_shards`$successful
#> [1] 5
#> 
#> $`_shards`$failed
#> [1] 0
#> 
#> 
#> $hits
#> $hits$total
#> [1] 1003
#> 
#> $hits$max_score
#> [1] 1
#> 
#> $hits$hits
#> $hits$hits[[1]]
#> $hits$hits[[1]]$`_index`
#> [1] "plos"
#> 
#> $hits$hits[[1]]$`_type`
#> [1] "article"
#> 
#> $hits$hits[[1]]$`_id`
#> [1] "4"
#> 
#> $hits$hits[[1]]$`_score`
#> [1] 1
#> 
#> $hits$hits[[1]]$`_source`
#> $hits$hits[[1]]$`_source`$id
#> [1] "10.1371/journal.pone.0107758"
#> 
#> $hits$hits[[1]]$`_source`$title
#> [1] "Lactobacilli Inactivate Chlamydia trachomatis through Lactic Acid but Not H2O2"
```


```r
es_search(index="plos", type="article", sort="title", q="antibody", size=1)
#> $took
#> [1] 1
#> 
#> $timed_out
#> [1] FALSE
#> 
#> $`_shards`
#> $`_shards`$total
#> [1] 5
#> 
#> $`_shards`$successful
#> [1] 5
#> 
#> $`_shards`$failed
#> [1] 0
#> 
#> 
#> $hits
#> $hits$total
#> [1] 5
#> 
#> $hits$max_score
#> NULL
#> 
#> $hits$hits
#> $hits$hits[[1]]
#> $hits$hits[[1]]$`_index`
#> [1] "plos"
#> 
#> $hits$hits[[1]]$`_type`
#> [1] "article"
#> 
#> $hits$hits[[1]]$`_id`
#> [1] "568"
#> 
#> $hits$hits[[1]]$`_score`
#> NULL
#> 
#> $hits$hits[[1]]$`_source`
#> $hits$hits[[1]]$`_source`$id
#> [1] "10.1371/journal.pone.0085002"
#> 
#> $hits$hits[[1]]$`_source`$title
#> [1] "Evaluation of 131I-Anti-Angiotensin II Type 1 Receptor Monoclonal Antibody as a Reporter for Hepatocellular Carcinoma"
#> 
#> 
#> $hits$hits[[1]]$sort
#> $hits$hits[[1]]$sort[[1]]
#> [1] "1"
```

### Get documents

Get document with id=1


```r
es_get(index='plos', type='article', id=1)
#> $`_index`
#> [1] "plos"
#> 
#> $`_type`
#> [1] "article"
#> 
#> $`_id`
#> [1] "1"
#> 
#> $`_version`
#> [1] 2
#> 
#> $found
#> [1] TRUE
#> 
#> $`_source`
#> $`_source`$id
#> [1] "10.1371/journal.pone.0098602"
#> 
#> $`_source`$title
#> [1] "Population Genetic Structure of a Sandstone Specialist and a Generalist Heath Species at Two Levels of Sandstone Patchiness across the Strait of Gibraltar"
```


Get certain fields


```r
es_get(index='plos', type='article', id=1, fields='id')
#> $`_index`
#> [1] "plos"
#> 
#> $`_type`
#> [1] "article"
#> 
#> $`_id`
#> [1] "1"
#> 
#> $`_version`
#> [1] 2
#> 
#> $found
#> [1] TRUE
#> 
#> $fields
#> $fields$id
#> $fields$id[[1]]
#> [1] "10.1371/journal.pone.0098602"
```


### Get multiple documents via the multiget API

Same index and type, different document ids


```r
es_mget(index="plos", type="article", id=1:2)
#> $docs
#> $docs[[1]]
#> $docs[[1]]$`_index`
#> [1] "plos"
#> 
#> $docs[[1]]$`_type`
#> [1] "article"
#> 
#> $docs[[1]]$`_id`
#> [1] "1"
#> 
#> $docs[[1]]$`_version`
#> [1] 2
#> 
#> $docs[[1]]$found
#> [1] TRUE
#> 
#> $docs[[1]]$`_source`
#> $docs[[1]]$`_source`$id
#> [1] "10.1371/journal.pone.0098602"
#> 
#> $docs[[1]]$`_source`$title
#> [1] "Population Genetic Structure of a Sandstone Specialist and a Generalist Heath Species at Two Levels of Sandstone Patchiness across the Strait of Gibraltar"
#> 
#> 
#> 
#> $docs[[2]]
#> $docs[[2]]$`_index`
#> [1] "plos"
#> 
#> $docs[[2]]$`_type`
#> [1] "article"
#> 
#> $docs[[2]]$`_id`
#> [1] "2"
#> 
#> $docs[[2]]$`_version`
#> [1] 2
#> 
#> $docs[[2]]$found
#> [1] TRUE
#> 
#> $docs[[2]]$`_source`
#> $docs[[2]]$`_source`$id
#> [1] "10.1371/journal.pone.0107757"
#> 
#> $docs[[2]]$`_source`$title
#> [1] "Cigarette Smoke Extract Induces a Phenotypic Shift in Epithelial Cells; Involvement of HIF1α in Mesenchymal Transition"
```

Different indeces, types, and ids


```r
es_mget(index_type_id=list(c("plos","article",1), c("gbif","record",1)))
#> $docs
#> $docs[[1]]
#> $docs[[1]]$`_index`
#> [1] "plos"
#> 
#> $docs[[1]]$`_type`
#> [1] "article"
#> 
#> $docs[[1]]$`_id`
#> [1] "1"
#> 
#> $docs[[1]]$`_version`
#> [1] 2
#> 
#> $docs[[1]]$found
#> [1] TRUE
#> 
#> $docs[[1]]$`_source`
#> $docs[[1]]$`_source`$id
#> [1] "10.1371/journal.pone.0098602"
#> 
#> $docs[[1]]$`_source`$title
#> [1] "Population Genetic Structure of a Sandstone Specialist and a Generalist Heath Species at Two Levels of Sandstone Patchiness across the Strait of Gibraltar"
#> 
#> 
#> 
#> $docs[[2]]
#> $docs[[2]]$`_index`
#> [1] "gbif"
#> 
#> $docs[[2]]$`_type`
#> [1] "record"
#> 
#> $docs[[2]]$`_id`
#> [1] "1"
#> 
#> $docs[[2]]$`_version`
#> [1] 1
#> 
#> $docs[[2]]$found
#> [1] TRUE
#> 
#> $docs[[2]]$`_source`
#> $docs[[2]]$`_source`$key
#> [1] 925277117
#> 
#> $docs[[2]]$`_source`$datasetKey
#> [1] "83e20573-f7dd-4852-9159-21566e1e691e"
#> 
#> $docs[[2]]$`_source`$publishingOrgKey
#> [1] "1cd669d0-80ea-11de-a9d0-f1765f95f18b"
#> 
#> $docs[[2]]$`_source`$publishingCountry
#> [1] "BE"
#> 
#> $docs[[2]]$`_source`$protocol
#> [1] "DWC_ARCHIVE"
#> 
#> $docs[[2]]$`_source`$lastCrawled
#> [1] "2014-07-17T19:23:36.333+0000"
#> 
#> $docs[[2]]$`_source`$lastParsed
#> [1] "2014-07-17T16:26:53.364+0000"
#> 
#> $docs[[2]]$`_source`$extensions
#> [1] "null"
#> 
#> $docs[[2]]$`_source`$basisOfRecord
#> [1] "MACHINE_OBSERVATION"
#> 
#> $docs[[2]]$`_source`$sex
#> [1] "FEMALE"
#> 
#> $docs[[2]]$`_source`$lifeStage
#> [1] "ADULT"
#> 
#> $docs[[2]]$`_source`$taxonKey
#> [1] 2481139
#> 
#> $docs[[2]]$`_source`$kingdomKey
#> [1] 1
#> 
#> $docs[[2]]$`_source`$phylumKey
#> [1] 44
#> 
#> $docs[[2]]$`_source`$classKey
#> [1] 212
#> 
#> $docs[[2]]$`_source`$orderKey
#> [1] 7192402
#> 
#> $docs[[2]]$`_source`$familyKey
#> [1] 9316
#> 
#> $docs[[2]]$`_source`$genusKey
#> [1] 2481126
#> 
#> $docs[[2]]$`_source`$speciesKey
#> [1] 2481139
#> 
#> $docs[[2]]$`_source`$scientificName
#> [1] "Larus argentatus Pontoppidan, 1763"
#> 
#> $docs[[2]]$`_source`$kingdom
#> [1] "Animalia"
#> 
#> $docs[[2]]$`_source`$phylum
#> [1] "Chordata"
#> 
#> $docs[[2]]$`_source`$order
#> [1] "Charadriiformes"
#> 
#> $docs[[2]]$`_source`$family
#> [1] "Laridae"
#> 
#> $docs[[2]]$`_source`$genus
#> [1] "Larus"
#> 
#> $docs[[2]]$`_source`$species
#> [1] "Larus argentatus"
#> 
#> $docs[[2]]$`_source`$genericName
#> [1] "Larus"
#> 
#> $docs[[2]]$`_source`$specificEpithet
#> [1] "argentatus"
#> 
#> $docs[[2]]$`_source`$taxonRank
#> [1] "SPECIES"
#> 
#> $docs[[2]]$`_source`$decimalLongitude
#> [1] 2.9258
#> 
#> $docs[[2]]$`_source`$decimalLatitude
#> [1] 51.1527
#> 
#> $docs[[2]]$`_source`$elevation
#> [1] 0
#> 
#> $docs[[2]]$`_source`$year
#> [1] 2014
#> 
#> $docs[[2]]$`_source`$month
#> [1] 1
#> 
#> $docs[[2]]$`_source`$day
#> [1] 13
#> 
#> $docs[[2]]$`_source`$eventDate
#> [1] "2014-01-13T14:28:19.000+0000"
#> 
#> $docs[[2]]$`_source`$issues
#> [1] "COORDINATE_ROUNDED,COUNTRY_DERIVED_FROM_COORDINATES,MODIFIED_DATE_UNLIKELY"
#> 
#> $docs[[2]]$`_source`$modified
#> [1] "2014-07-17T09:47:54.000+0000"
#> 
#> $docs[[2]]$`_source`$lastInterpreted
#> [1] "2014-07-17T16:44:59.331+0000"
#> 
#> $docs[[2]]$`_source`$identifiers
#> [1] "null"
#> 
#> $docs[[2]]$`_source`$facts
#> [1] "null"
#> 
#> $docs[[2]]$`_source`$relations
#> [1] "null"
#> 
#> $docs[[2]]$`_source`$geodeticDatum
#> [1] "WGS84"
#> 
#> $docs[[2]]$`_source`$class
#> [1] "Aves"
#> 
#> $docs[[2]]$`_source`$countryCode
#> [1] "BE"
#> 
#> $docs[[2]]$`_source`$country
#> [1] "Belgium"
#> 
#> $docs[[2]]$`_source`$informationWithheld
#> [1] "see metadata"
#> 
#> $docs[[2]]$`_source`$georeferencedDate
#> [1] "2014-01-13T15:28:19Z"
#> 
#> $docs[[2]]$`_source`$georeferenceVerificationStatus
#> [1] "unverified"
#> 
#> $docs[[2]]$`_source`$nomenclaturalCode
#> [1] "ICZN"
#> 
#> $docs[[2]]$`_source`$individualID
#> [1] "H903183"
#> 
#> $docs[[2]]$`_source`$rights
#> [1] "http://creativecommons.org/publicdomain/zero/1.0/"
#> 
#> $docs[[2]]$`_source`$rightsHolder
#> [1] "INBO"
#> 
#> $docs[[2]]$`_source`$ownerInstitutionCode
#> [1] "INBO"
#> 
#> $docs[[2]]$`_source`$type
#> [1] "Event"
#> 
#> $docs[[2]]$`_source`$georeferenceProtocol
#> [1] "doi:10.1080/13658810412331280211"
#> 
#> $docs[[2]]$`_source`$occurrenceID
#> [1] "125254"
#> 
#> $docs[[2]]$`_source`$georeferenceSources
#> [1] "GPS"
#> 
#> $docs[[2]]$`_source`$vernacularName
#> [1] "Herring Gull"
#> 
#> $docs[[2]]$`_source`$gbifID
#> [1] "925277117"
#> 
#> $docs[[2]]$`_source`$samplingEffort
#> [1] "secondsSinceLastOccurrence=895"
#> 
#> $docs[[2]]$`_source`$samplingProtocol
#> [1] "doi:10.1007/s10336-012-0908-1"
#> 
#> $docs[[2]]$`_source`$institutionCode
#> [1] "INBO"
#> 
#> $docs[[2]]$`_source`$datasetID
#> [1] "http://dataset.inbo.be/bird-tracking-gull-occurrences"
#> 
#> $docs[[2]]$`_source`$dynamicProperties
#> [1] "device_info_serial=783"
#> 
#> $docs[[2]]$`_source`$datasetName
#> [1] "Bird tracking - GPS tracking of Lesser Black-backed Gull and Herring Gull breeding at the Belgian coast"
#> 
#> $docs[[2]]$`_source`$minimumDistanceAboveSurfaceInMeters
#> [1] "11"
#> 
#> $docs[[2]]$`_source`$language
#> [1] "en"
#> 
#> $docs[[2]]$`_source`$identifier
#> [1] "125254"
```

### Parsing

`es_parse` is a general purpose parser function with extension methods `es_parse.es_search`, `es_parse.es_get`, and `es_parse.es_mget`, for parsing `es_search`, `es_get`, and `es_mget` function output, respectively. `es_parse` is used internally within those three functions (`es_search`, `es_get`, `es_mget`) to do parsing. You can optionally get back raw `json` from `es_search`, `es_get`, and `es_mget` setting parameter `raw=TRUE`, and then parsing after with `es_parse`.

For example:


```r
(out <- es_mget(index="plos", type="article", id=1:2, raw=TRUE))
#> [1] "{\"docs\":[{\"_index\":\"plos\",\"_type\":\"article\",\"_id\":\"1\",\"_version\":2,\"found\":true,\"_source\":{\"id\":\"10.1371/journal.pone.0098602\",\"title\":\"Population Genetic Structure of a Sandstone Specialist and a Generalist Heath Species at Two Levels of Sandstone Patchiness across the Strait of Gibraltar\"}},{\"_index\":\"plos\",\"_type\":\"article\",\"_id\":\"2\",\"_version\":2,\"found\":true,\"_source\":{\"id\":\"10.1371/journal.pone.0107757\",\"title\":\"Cigarette Smoke Extract Induces a Phenotypic Shift in Epithelial Cells; Involvement of HIF1α in Mesenchymal Transition\"}}]}"
#> attr(,"class")
#> [1] "elastic_mget"
```

Then parse


```r
es_parse(out)
#> $docs
#> $docs[[1]]
#> $docs[[1]]$`_index`
#> [1] "plos"
#> 
#> $docs[[1]]$`_type`
#> [1] "article"
#> 
#> $docs[[1]]$`_id`
#> [1] "1"
#> 
#> $docs[[1]]$`_version`
#> [1] 2
#> 
#> $docs[[1]]$found
#> [1] TRUE
#> 
#> $docs[[1]]$`_source`
#> $docs[[1]]$`_source`$id
#> [1] "10.1371/journal.pone.0098602"
#> 
#> $docs[[1]]$`_source`$title
#> [1] "Population Genetic Structure of a Sandstone Specialist and a Generalist Heath Species at Two Levels of Sandstone Patchiness across the Strait of Gibraltar"
#> 
#> 
#> 
#> $docs[[2]]
#> $docs[[2]]$`_index`
#> [1] "plos"
#> 
#> $docs[[2]]$`_type`
#> [1] "article"
#> 
#> $docs[[2]]$`_id`
#> [1] "2"
#> 
#> $docs[[2]]$`_version`
#> [1] 2
#> 
#> $docs[[2]]$found
#> [1] TRUE
#> 
#> $docs[[2]]$`_source`
#> $docs[[2]]$`_source`$id
#> [1] "10.1371/journal.pone.0107757"
#> 
#> $docs[[2]]$`_source`$title
#> [1] "Cigarette Smoke Extract Induces a Phenotypic Shift in Epithelial Cells; Involvement of HIF1α in Mesenchymal Transition"
```

## CouchDB integration

### __Optionally__ install CouchDB River plugin for Elasticsearch

+ Navigate to elastisearch dir: `cd elasticsearch`
+ Install it: `bin/plugin -install elasticsearch/elasticsearch-river-couchdb/2.0.0.RC1`

### Start Elasticsearch

+ Navigate to elasticsearch: `cd /usr/local/elasticsearch`
+ Start elasticsearch: `bin/elasticsearch -f`

### Make call to elasticsearch to start indexing (and always index) your database

Edit details and paste into terminal and execute

curl -XPUT 'localhost:9200/_river/rplos_db/_meta' -d '{
"type" : "couchdb",
"couchdb" : {
"host" : "localhost",
"port" : 5984,
"db" : "rplos_db",
"filter" : null
}
}'

### Searching

#### At the cli...

```sh
curl -XGET "http://localhost:9200/sofadb/_search?q=road&pretty=true"

{
"took" : 3,
"timed_out" : false,
"_shards" : {
"total" : 5,
"successful" : 5,
"failed" : 0
},
"hits" : {
"total" : 2,
"max_score" : 0.614891,
"hits" : [ {
"_index" : "sofadb",
"_type" : "sofadb",
"_id" : "a1812100bd1dba00c2ed1cd507000277",
"_score" : 0.614891, "_source" : {"_rev":"1-5406480672da172726810767e7d0ead3","_id":"a1812100bd1dba00c2ed1cd507000277","name":"sofa","icecream":"rocky road"}
}, {
"_index" : "sofadb",
"_type" : "sofadb",
"_id" : "a1812100bd1dba00c2ed1cd507000b92",
"_score" : 0.13424811, "_source" : {"_rev":"1-5406480672da172726810767e7d0ead3","_id":"a1812100bd1dba00c2ed1cd507000b92","name":"sofa","icecream":"rocky road"}
} ]
}
}
```

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/elastic/issues)
* License: MIT
* Get citation information for `elastic` in R doing `citation(package = 'elastic')`

[![](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
