elastic
=======

[![Build Status](https://api.travis-ci.org/sckott/elastic.png)](https://travis-ci.org/sckott/elastic)

**A general purpose R interface to [Elasticsearch](http://elasticsearch.org)**


### Elasticsearch info

+ [Elasticsearch home page](http://elasticsearch.org)

### Notes

XXXX

### Quick start

**Install**

Install dependencies

```coffee
install.packages(c("rjson","plyr","httr","XML"))
```

Install solr

```coffee
install.packages("devtools")
library(devtools)
install_github("sckott/elastic")
library(elastic)
```

**Define stuff** Your base url and a key (if needed). This example should work. You do need to pass a key to the Public Library of Science search API, but it apparently doesn't need to be a real one.

```coffee
url <- 'http://localhost:92/search'
key <- 'key'
```

### Install Elasticsearch (on OSX)

+ Download zip or tar file
+ Unzip it: `unzip or untar`
+ Move it: `sudo mv /path/to/elasticsearch-0.20.6 /usr/local`
+ Navigate to /usr/local: `cd /usr/local`
+ Add shortcut: `sudo ln -s elasticsearch-0.20.6 elasticsearch`

### Install CouchDB River plugin for Elasticsearch

+ Navigate to elastisearch dir: `cd elasticsearch`
+ Install it: `bin/plugin -install elasticsearch/elasticsearch-river-couchdb/1.1.0`

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
elastic_search(dbname="sofadb", q="road")
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