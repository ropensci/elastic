elastic
=======

[![Build Status](https://api.travis-ci.org/ropensci/elastic.png)](https://travis-ci.org/ropensci/elastic)
[![Build status](https://ci.appveyor.com/api/projects/status/swmmw758mf1heoj2/branch/master)](https://ci.appveyor.com/project/sckott/elastic/branch/master)

**A general purpose R interface to [Elasticsearch](http://elasticsearch.org)**


## Elasticsearch info

+ [Elasticsearch home page](http://elasticsearch.org)
+ [API docs](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/index.html)
+ xxxx

## Notes

* This client is being developed under v1.0 of Elasticsearch.
* It is early days for this client, so do help us by submitting bug reports and feature requests on the issue tracker.

## Function names

To avoid potential conflicts with other R packges, this package adds `es_` as a prefix to every function.

## Quick start

### Install elastic

Install dependencies

```coffee
install.packages(c("jsonlite","plyr","httr"))
```

Install elastic

```coffee
install.packages("devtools")
library(devtools)
install_github("ropensci/elastic")
library(elastic)
```

### Install Elasticsearch (on OSX)

+ Download zip or tar file from Elasticsearch [see here for download](http://www.elasticsearch.org/overview/elkdownloads/)
+ Unzip it: `unzip` or `untar`
+ Move it: `sudo mv /path/to/elasticsearch-1.3.4 /usr/local` (replace version with your verioon)
+ Navigate to /usr/local: `cd /usr/local`
+ Add shortcut: `sudo ln -s elasticsearch-1.3.4 elasticsearch` (replace version with your verioon)

### Start Elasticsearch

* Navigate to elasticsearch: `cd /usr/local/elasticsearch`
* Start elasticsearch: `bin/elasticsearch`

I create a little bash shortcut called `es` that does both of the above commands in one step.

### Get some data

#### Shakespeare data

If you need some big data to play with, the shakespeare dataset is a good one to start with. First, download the dataset using curl or wget:

```sh
curl -XGET http://www.elasticsearch.org/guide/en/kibana/current/snippets/shakespeare.json > shakespeare.json
```

Then load the data into Elasticsearch. This may take up to 10 minutes or so.

```sh
curl -XPUT localhost:9200/_bulk --data-binary @shakespeare.json
```

#### Public Library of Science (PLOS) data

Some smaller data can be retrieved from the PLOS search API. First, download the dataset using `curl`, and pipe through [jq](http://stedolan.github.io/jq/) to get only the `docs` elements:

```sh
curl -XGET "http://api.plos.org/search?wt=json&q=*:*&rows=1000" | jq ".response.docs" > json.plos
```

Then load the data into Elasticsearch. This may take up to 10 minutes or so.

```sh
curl -XPUT localhost:9200/_bulk --data-binary @plos.json
```

### Initialization

The function `es_connect` is used before doing anything else to set the connection details to your remote or local elasticsearch store. The details created by `es_connect` are written to your options for the current session, and are used by `elastic` functions.

```
es_connect()
```

### Search

```coffee
es_search(index="twitter")
```

```coffee
matches -> 6
score -> 1
$took
[1] 1

$timed_out
[1] FALSE

$`_shards`
$`_shards`$total
[1] 5

$`_shards`$successful
[1] 5

$`_shards`$failed
[1] 0


$hits
$hits$total
[1] 6

$hits$max_score
[1] 1

$hits$hits
$hits$hits[[1]]
$hits$hits[[1]]$`_index`
[1] "twitter"
```


```coffee
es_search(index="twitter", type="tweet", sort="message")
```

```coffee
matches -> 3
score -> NA
$took
[1] 2

$timed_out
[1] FALSE

$`_shards`
$`_shards`$total
[1] 5

$`_shards`$successful
[1] 5

$`_shards`$failed
[1] 0


$hits
$hits$total
[1] 3

$hits$max_score
NULL

$hits$hits
$hits$hits[[1]]
$hits$hits[[1]]$`_index`
[1] "twitter"

$hits$hits[[1]]$`_type`
[1] "tweet"

$hits$hits[[1]]$`_id`
[1] "3"

$hits$hits[[1]]$`_score`
NULL

$hits$hits[[1]]$`_source`
$hits$hits[[1]]$`_source`$user
[1] "jane"

$hits$hits[[1]]$`_source`$post_date
[1] "2009-11-15T14:12:12"

...
```

### Get documents

Get document with id=1

```coffee
es_get(index='twitter', type='tweet', id=1)
```

```coffee
http://127.0.0.1:9200/?=
$ok
[1] TRUE

$status
[1] 200

$name
[1] "Simon Williams"

$version
$version$number
[1] "0.90.11"

$version$build_hash
[1] "11da1bacf39cec400fd97581668acb2c5450516c"

$version$build_timestamp
[1] "2014-02-03T15:27:39Z"

$version$build_snapshot
[1] FALSE

$version$lucene_version
[1] "4.6"


$tagline
[1] "You Know, for Search"

attr(,"class")
[1] "elastic"
```

Get certain fields

```coffee
es_get(index='twitter', type='tweet', id=1, fields='user')
```

```coffee
http://127.0.0.1:9200/?fields=user
$ok
[1] TRUE

$status
[1] 200

$name
[1] "Simon Williams"

$version
$version$number
[1] "0.90.11"

$version$build_hash
[1] "11da1bacf39cec400fd97581668acb2c5450516c"

$version$build_timestamp
[1] "2014-02-03T15:27:39Z"

$version$build_snapshot
[1] FALSE

$version$lucene_version
[1] "4.6"


$tagline
[1] "You Know, for Search"

attr(,"class")
[1] "elastic"
```

Test for existence of the document

```coffee
es_get(index='twitter', type='tweet', id=1, exists=TRUE)
```

```coffee
200 - OK
```

### Get multiple documents via the multiget API

Same index and type, different document ids

```coffee
es_mget(index="twitter", type="tweet", id=1:2)
```

```coffee
$docs
$docs[[1]]
$docs[[1]]$`_index`
[1] "twitter"

$docs[[1]]$`_type`
[1] "tweet"

$docs[[1]]$`_id`
[1] "1"

$docs[[1]]$`_version`
[1] 1

$docs[[1]]$exists
[1] TRUE

$docs[[1]]$`_source`
$docs[[1]]$`_source`$user
[1] "kimchy"

$docs[[1]]$`_source`$post_date
[1] "2009-11-15T14:12:12"

$docs[[1]]$`_source`$message
[1] "trying out Elasticsearch"



$docs[[2]]
$docs[[2]]$`_index`
[1] "twitter"

$docs[[2]]$`_type`
[1] "tweet"

$docs[[2]]$`_id`
[1] "2"

$docs[[2]]$`_version`
[1] 1

$docs[[2]]$exists
[1] TRUE

$docs[[2]]$`_source`
$docs[[2]]$`_source`$user
[1] "scott"

$docs[[2]]$`_source`$post_date
[1] "2009-11-15T14:12:12"

$docs[[2]]$`_source`$message
[1] "what shit what what"

```

Different indeces, types, and ids

```coffee
es_mget(index_type_id=list(c("twitter","mention",1), c("appdotnet","share",1)))
```

```coffee
$docs
$docs[[1]]
$docs[[1]]$`_index`
[1] "twitter"

$docs[[1]]$`_type`
[1] "mention"

$docs[[1]]$`_id`
[1] "1"

$docs[[1]]$`_version`
[1] 1

$docs[[1]]$exists
[1] TRUE

$docs[[1]]$`_source`
$docs[[1]]$`_source`$user
[1] "sam"

$docs[[1]]$`_source`$post_date
[1] "2009-11-15T14:12:12"

$docs[[1]]$`_source`$message
[1] "lorum ipsum"



$docs[[2]]
$docs[[2]]$`_index`
[1] "appdotnet"

$docs[[2]]$`_type`
[1] "share"

$docs[[2]]$`_id`
[1] "1"

$docs[[2]]$`_version`
[1] 1

$docs[[2]]$exists
[1] TRUE

$docs[[2]]$`_source`
$docs[[2]]$`_source`$user
[1] "bob"

$docs[[2]]$`_source`$post_date
[1] "2009-11-15T14:12:12"

$docs[[2]]$`_source`$message
[1] "hello world"
```

### Parsing

`es_parse` is a general purpose parser function with extension methods `es_parse.es_search`, `es_parse.es_get`, and `es_parse.es_mget`, for parsing `es_search`, `es_get`, and `es_mget` function output, respectively. `es_parse` is used internally within those three functions (`es_search`, `es_get`, `es_mget`) to do parsing. You can optionally get back raw `json` from `es_search`, `es_get`, and `es_mget` setting parameter `raw=TRUE`, and then parsing after with `es_parse`.

For example:

```coffee
(out <- es_mget(index="twitter", type="tweet", id=1:2, raw=TRUE))
```

```coffee
[1] "{\"docs\":[{\"_index\":\"twitter\",\"_type\":\"tweet\",\"_id\":\"1\",\"error\":\"NoShardAvailableActionException[[twitter][2] null]\"},{\"_index\":\"twitter\",\"_type\":\"tweet\",\"_id\":\"2\",\"error\":\"NoShardAvailableActionException[[twitter][3] null]\"}]}"
attr(,"class")
[1] "elastic_mget"
```

Then parse

```coffee
es_parse(out)
```

```coffee
$docs
$docs[[1]]
$docs[[1]]$`_index`
[1] "twitter"

$docs[[1]]$`_type`
[1] "tweet"

$docs[[1]]$`_id`
[1] "1"

$docs[[1]]$`_version`
[1] 1

$docs[[1]]$exists
[1] TRUE

$docs[[1]]$`_source`
$docs[[1]]$`_source`$user
[1] "kimchy"

$docs[[1]]$`_source`$post_date
[1] "2009-11-15T14:12:12"

$docs[[1]]$`_source`$message
[1] "trying out Elasticsearch"



$docs[[2]]
$docs[[2]]$`_index`
[1] "twitter"

$docs[[2]]$`_type`
[1] "tweet"

$docs[[2]]$`_id`
[1] "2"

$docs[[2]]$`_version`
[1] 1

$docs[[2]]$exists
[1] TRUE

$docs[[2]]$`_source`
$docs[[2]]$`_source`$user
[1] "scott"

$docs[[2]]$`_source`$post_date
[1] "2009-11-15T14:12:12"

$docs[[2]]$`_source`$message
[1] "what shit what what"
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
