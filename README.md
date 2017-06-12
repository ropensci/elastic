elastic
=======



[![Build Status](https://api.travis-ci.org/ropensci/elastic.svg)](https://travis-ci.org/ropensci/elastic)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/elastic?color=E664A4)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/elastic)](https://cran.r-project.org/package=elastic)
[![codecov.io](https://codecov.io/github/ropensci/elastic/coverage.svg?branch=master)](https://codecov.io/github/ropensci/elastic?branch=master)
<!-- [![Build status](https://ci.appveyor.com/api/projects/status/swmmw758mf1heoj2/branch/master)](https://ci.appveyor.com/project/sckott/elastic/branch/master) -->

**A general purpose R interface to [Elasticsearch](https://www.elastic.co/products/elasticsearch)**

## Elasticsearch DSL

Also check out `elasticdsl` - an R DSL for Elasticsearch - [https://github.com/ropensci/elasticdsl](https://github.com/ropensci/elasticdsl)

## Elasticsearch info

* [Elasticsearch home page](https://www.elastic.co/products/elasticsearch)
* [API docs](http://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)


## Compatibility

This client is developed following the latest stable releases, currently `v5.4.0`. It is generally compatible with older versions of Elasticsearch. Unlike the [Python client](https://github.com/elastic/elasticsearch-py#compatibility), we try to keep as much compatibility as possible within a single version of this client, as that's an easier setup in R world.

## Security

You're fine running ES locally on your machine, but be careful just throwing up ES on a server with a public IP address - make sure to think about security.

* [Shield](https://www.elastic.co/products/shield) - This is a paid product provided by Elastic - so probably only applicable to enterprise users
* DIY security - there are a variety of techniques for securing your Elasticsearch. A number of resources are collected in a [blog post](http://recology.info/2015/02/secure-elasticsearch/) - tools include putting your ES behind something like Nginx, putting basic auth on top of it, using https, etc.

## Installation

Stable version from CRAN


```r
install.packages("elastic")
```

Development version from GitHub


```r
install.packages("devtools")
devtools::install_github("ropensci/elastic")
```


```r
library('elastic')
```

## Install Elasticsearch

* [Elasticsearch installation help](https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html)

__w/ Docker__

Pull the official elasticsearch image

```
docker pull elasticsearch
```

Then start up a container

```
docker run -d -p 9200:9200 elasticsearch
```

Then elasticsearch should be available on port 9200, try `curl localhost:9200` and you should get the familiar message indicating ES is on.

If you're using boot2docker, you'll need to use the IP address in place of localhost. Get it by doing `boot2docker ip`.

__on OSX__

+ Download zip or tar file from Elasticsearch [see here for download](https://www.elastic.co/downloads), e.g., `curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.4.0.tar.gz`
+ Extract: `tar -zxvf elasticsearch-5.4.0.tar.gz`
+ Move it: `sudo mv elasticsearch-5.4.0 /usr/local`
+ Navigate to /usr/local: `cd /usr/local`
+ Delete symlinked `elasticsearch` directory: `rm -rf elasticsearch`
+ Add shortcut: `sudo ln -s elasticsearch-5.4.0 elasticsearch` (replace version with your version)

You can also install via Homebrew: `brew install elasticsearch`

> Note: for the 1.6 and greater upgrades of Elasticsearch, they want you to have java 8 or greater. I downloaded Java 8 from here http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html and it seemed to work great.

## Upgrading Elasticsearch

I am not totally clear on best practice here, but from what I understand, when you upgrade to a new version of Elasticsearch, place old `elasticsearch/data` and `elasticsearch/config` directories into the new installation (`elasticsearch/` dir). The new elasticsearch instance with replaced data and config directories should automatically update data to the new version and start working. Maybe if you use homebrew on a Mac to upgrade it takes care of this for you - not sure.

Obviously, upgrading Elasticsearch while keeping it running is a different thing ([some help here from Elastic](http://www.elastic.co/guide/en/elasticsearch/reference/current/setup-upgrade.html)).

## Start Elasticsearch

* Navigate to elasticsearch: `cd /usr/local/elasticsearch`
* Start elasticsearch: `bin/elasticsearch`

I create a little bash shortcut called `es` that does both of the above commands in one step (`cd /usr/local/elasticsearch && bin/elasticsearch`).

## Get some data

Elasticsearch has a bulk load API to load data in fast. The format is pretty weird though. It's sort of JSON, but would pass no JSON linter. I include a few data sets in `elastic` so it's easy to get up and running, and so when you run examples in this package they'll actually run the same way (hopefully).

I have prepare a non-exported function useful for preparing the weird format that Elasticsearch wants for bulk data loads, that is somewhat specific to PLOS data (See below), but you could modify for your purposes. See `make_bulk_plos()` and `make_bulk_gbif()` [here](https://github.com/ropensci/elastic/blob/master/R/docs_bulk.r).

### Shakespeare data

Elasticsearch provides some data on Shakespeare plays. I've provided a subset of this data in this package. Get the path for the file specific to your machine:


```r
shakespeare <- system.file("examples", "shakespeare_data.json", package = "elastic")
```

Then load the data into Elasticsearch:


```r
invisible(docs_bulk(shakespeare))
```

If you need some big data to play with, the shakespeare dataset is a good one to start with. You can get the whole thing and pop it into Elasticsearch (beware, may take up to 10 minutes or so.):

```sh
curl -XGET https://www.elastic.co/guide/en/kibana/3.0/snippets/shakespeare.json > shakespeare.json
curl -XPUT localhost:9200/_bulk --data-binary @shakespeare.json
```

### Public Library of Science (PLOS) data

A dataset inluded in the `elastic` package is metadata for PLOS scholarly articles. Get the file path, then load:


```r
plosdat <- system.file("examples", "plos_data.json", package = "elastic")
invisible(docs_bulk(plosdat))
```

### Global Biodiversity Information Facility (GBIF) data

A dataset inluded in the `elastic` package is data for GBIF species occurrence records. Get the file path, then load:


```r
gbifdat <- system.file("examples", "gbif_data.json", package = "elastic")
invisible(docs_bulk(gbifdat))
```

GBIF geo data with a coordinates element to allow `geo_shape` queries


```r
gbifgeo <- system.file("examples", "gbif_geo.json", package = "elastic")
invisible(docs_bulk(gbifgeo))
```

### More data sets

There are more datasets formatted for bulk loading in the `ropensci/elastic_data` GitHub repository. Find it at [https://github.com/ropensci/elastic_data](https://github.com/ropensci/elastic_data)

## Initialization

The function `connect()` is used before doing anything else to set the connection details to your remote or local elasticsearch store. The details created by `connect()` are written to your options for the current session, and are used by `elastic` functions.


```r
connect(es_port = 9200)
#> transport:  http 
#> host:       127.0.0.1 
#> port:       9200 
#> path:       NULL 
#> username:   NULL 
#> password:   <secret> 
#> errors:     simple 
#> headers (names):  NULL
```

For AWS hosted elasticsearch, make sure to specify es_path = "" and the correct port - transport schema pair.


```r
connect(es_host = <aws_es_endpoint>, es_path = "", es_port = 80, es_transport_schema  = "http")
  # or
connect(es_host = <aws_es_endpoint>, es_path = "", es_port = 443, es_transport_schema  = "https")
```

## Search

Search the `plos` index and only return 1 result


```r
Search(index = "plos", size = 1)$hits$hits
#> Error: 404 - no such index
```

Search the `plos` index, and the `article` document type, and query for _antibody_, limit to 1 result


```r
Search(index = "plos", type = "article", q = "antibody", size = 1)$hits$hits
#> Error: 404 - no such index
```

## Get documents

Get document with id=1


```r
docs_get(index = 'plos', type = 'article', id = 4)
#> Error: 404 - no such index
```

Get certain fields


```r
docs_get(index = 'plos', type = 'article', id = 4, fields = 'id')
#> Error: 404 - no such index
```


## Get multiple documents via the multiget API

Same index and type, different document ids


```r
docs_mget(index = "plos", type = "article", id = 1:2)
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
#> $docs[[1]]$error
#> $docs[[1]]$error$root_cause
#> $docs[[1]]$error$root_cause[[1]]
#> $docs[[1]]$error$root_cause[[1]]$type
#> [1] "index_not_found_exception"
#> 
#> $docs[[1]]$error$root_cause[[1]]$reason
#> [1] "no such index"
#> 
#> $docs[[1]]$error$root_cause[[1]]$resource.type
#> [1] "index_expression"
#> 
#> $docs[[1]]$error$root_cause[[1]]$resource.id
#> [1] "plos"
#> 
#> $docs[[1]]$error$root_cause[[1]]$index_uuid
#> [1] "_na_"
#> 
#> $docs[[1]]$error$root_cause[[1]]$index
#> [1] "plos"
#> 
#> 
#> 
#> $docs[[1]]$error$type
#> [1] "index_not_found_exception"
#> 
#> $docs[[1]]$error$reason
#> [1] "no such index"
#> 
#> $docs[[1]]$error$resource.type
#> [1] "index_expression"
#> 
#> $docs[[1]]$error$resource.id
#> [1] "plos"
#> 
#> $docs[[1]]$error$index_uuid
#> [1] "_na_"
#> 
#> $docs[[1]]$error$index
#> [1] "plos"
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
#> $docs[[2]]$error
#> $docs[[2]]$error$root_cause
#> $docs[[2]]$error$root_cause[[1]]
#> $docs[[2]]$error$root_cause[[1]]$type
#> [1] "index_not_found_exception"
#> 
#> $docs[[2]]$error$root_cause[[1]]$reason
#> [1] "no such index"
#> 
#> $docs[[2]]$error$root_cause[[1]]$resource.type
#> [1] "index_expression"
#> 
#> $docs[[2]]$error$root_cause[[1]]$resource.id
#> [1] "plos"
#> 
#> $docs[[2]]$error$root_cause[[1]]$index_uuid
#> [1] "_na_"
#> 
#> $docs[[2]]$error$root_cause[[1]]$index
#> [1] "plos"
#> 
#> 
#> 
#> $docs[[2]]$error$type
#> [1] "index_not_found_exception"
#> 
#> $docs[[2]]$error$reason
#> [1] "no such index"
#> 
#> $docs[[2]]$error$resource.type
#> [1] "index_expression"
#> 
#> $docs[[2]]$error$resource.id
#> [1] "plos"
#> 
#> $docs[[2]]$error$index_uuid
#> [1] "_na_"
#> 
#> $docs[[2]]$error$index
#> [1] "plos"
```

Different indeces, types, and ids


```r
docs_mget(index_type_id = list(c("plos", "article", 1), c("gbif", "record", 1)))$docs[[1]]
#> $`_index`
#> [1] "plos"
#> 
#> $`_type`
#> [1] "article"
#> 
#> $`_id`
#> [1] "1"
#> 
#> $error
#> $error$root_cause
#> $error$root_cause[[1]]
#> $error$root_cause[[1]]$type
#> [1] "index_not_found_exception"
#> 
#> $error$root_cause[[1]]$reason
#> [1] "no such index"
#> 
#> $error$root_cause[[1]]$resource.type
#> [1] "index_expression"
#> 
#> $error$root_cause[[1]]$resource.id
#> [1] "plos"
#> 
#> $error$root_cause[[1]]$index_uuid
#> [1] "_na_"
#> 
#> $error$root_cause[[1]]$index
#> [1] "plos"
#> 
#> 
#> 
#> $error$type
#> [1] "index_not_found_exception"
#> 
#> $error$reason
#> [1] "no such index"
#> 
#> $error$resource.type
#> [1] "index_expression"
#> 
#> $error$resource.id
#> [1] "plos"
#> 
#> $error$index_uuid
#> [1] "_na_"
#> 
#> $error$index
#> [1] "plos"
```

## Parsing

You can optionally get back raw `json` from `Search()`, `docs_get()`, and `docs_mget()` setting parameter `raw=TRUE`.

For example:


```r
(out <- docs_mget(index = "plos", type = "article", id = 1:2, raw = TRUE))
#> [1] "{\"docs\":[{\"_index\":\"plos\",\"_type\":\"article\",\"_id\":\"1\",\"error\":{\"root_cause\":[{\"type\":\"index_not_found_exception\",\"reason\":\"no such index\",\"resource.type\":\"index_expression\",\"resource.id\":\"plos\",\"index_uuid\":\"_na_\",\"index\":\"plos\"}],\"type\":\"index_not_found_exception\",\"reason\":\"no such index\",\"resource.type\":\"index_expression\",\"resource.id\":\"plos\",\"index_uuid\":\"_na_\",\"index\":\"plos\"}},{\"_index\":\"plos\",\"_type\":\"article\",\"_id\":\"2\",\"error\":{\"root_cause\":[{\"type\":\"index_not_found_exception\",\"reason\":\"no such index\",\"resource.type\":\"index_expression\",\"resource.id\":\"plos\",\"index_uuid\":\"_na_\",\"index\":\"plos\"}],\"type\":\"index_not_found_exception\",\"reason\":\"no such index\",\"resource.type\":\"index_expression\",\"resource.id\":\"plos\",\"index_uuid\":\"_na_\",\"index\":\"plos\"}}]}"
#> attr(,"class")
#> [1] "elastic_mget"
```

Then parse


```r
jsonlite::fromJSON(out)
#> $docs
#>   _index   _type _id
#> 1   plos article   1
#> 2   plos article   2
#>                                                               error.root_cause
#> 1 index_not_found_exception, no such index, index_expression, plos, _na_, plos
#> 2 index_not_found_exception, no such index, index_expression, plos, _na_, plos
#>                  error.type  error.reason error.resource.type
#> 1 index_not_found_exception no such index    index_expression
#> 2 index_not_found_exception no such index    index_expression
#>   error.resource.id error.index_uuid error.index
#> 1              plos             _na_        plos
#> 2              plos             _na_        plos
```

## Known pain points

* On secure Elasticsearch servers:
  * `HEAD` requests don't seem to work, not sure why
  * If you allow only `GET` requests, a number of functions that require
  `POST` requests obviously then won't work. A big one is `Search()`, but
  you can use `Search_uri()` to get around this, which uses `GET` instead
  of `POST`, but you can't pass a more complicated query via the body

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/elastic/issues)
* License: MIT
* Get citation information for `elastic` in R doing `citation(package = 'elastic')`
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md).
By participating in this project you agree to abide by its terms.

[![rofooter](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
