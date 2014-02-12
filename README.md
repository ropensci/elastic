elastic
=======

[![Build Status](https://api.travis-ci.org/ropensci/elastic.png)](https://travis-ci.org/ropensci/elastic)

**A general purpose R interface to [Elasticsearch](http://elasticsearch.org)**


### Elasticsearch info

+ [Elasticsearch home page](http://elasticsearch.org)

### Notes

* This client is being developed under v1.0 of Elasticsearch.
* It is early days for this client, so do help us by submitting bug reports and feature requests on the issue tracker.

### Function names

To avoid potential conflicts with other R packges, this package adds `es_` as a prefix to every function.

### Quick start

**Install**

Install dependencies

```coffee
install.packages(c("rjson","plyr","httr"))
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
+ Unzip it: `unzip or untar`
+ Move it: `sudo mv /path/to/elasticsearch-1.0.0 /usr/local` (replace version with your verioon)
+ Navigate to /usr/local: `cd /usr/local`
+ Add shortcut: `sudo ln -s elasticsearch-1.0.0 elasticsearch` (replace version with your verioon)

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

#### In R...

```coffee
es_search(dbname="sofadb", q="road")
...

$hits$hits[[3]]
$hits$hits[[3]]$`_index`
[1] "sofadb"

$hits$hits[[3]]$`_type`
[1] "sofadb"

$hits$hits[[3]]$`_id`
[1] "a1812100bd1dba00c2ed1cd507000277"

$hits$hits[[3]]$`_score`
[1] 1
```