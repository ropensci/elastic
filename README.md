elastic
=======

<pre>
  _ _ _ _ _ _ _ _ _ _ _ 
 /|                   |\
/ |_ _ _ _ _ _ _ _ _ _| \
\ /                    \/
 \ ___________________ /
</pre>

#### *An easy interface to CouchDB from R*

Note: Check out [*R4couchdb*](https://github.com/wactbprot/R4CouchDB), another R package to interact with CouchDB. 

## Quickstart

### Install CouchDB

Instructions [here](http://wiki.apache.org/couchdb/Installation)

### Connect to CouchDB

In your terminal 

```sh
couchdb
```

You can interact with your CouchDB databases as well in your browser. Navigate to [http://localhost:5984/_utils](http://localhost:5984/_utils)

### Install sofa

from github obviously

```ruby
install.packages("devtools")
library(devtools)
install_github("sofa", "schamberlain")
library(sofa)
```

### Ping the server

```ruby
 sofa_ping()

  couchdb   version 
"Welcome"   "1.2.1" 
```

Nice, it's working.

### Create a new database, and list available databases

```ruby
sofa_createdb(dbname='sofadb')

  ok 
TRUE 

sofa_listdbs() # see if its there now

[1] "sofadb"
```

### Create documents

#### Write a document WITH a name (uses PUT)
```ruby
doc1 <- '{"name":"sofa","beer":"IPA"}'
sofa_writedoc(dbname="sofadb", doc=doc1, docid="sofasbeer")

$ok
[1] TRUE

$id
[1] "sofasbeer"

$rev
[1] "3-60b547ef0b162af1b3891f1955d46e66"
```

#### Write a json document WITHOUT a name (uses POST)
```ruby
doc2 <- '{"name":"sofa","icecream":"rocky road"}'
sofa_writedoc(dbname="sofadb", doc=doc2)

$ok
[1] TRUE

$id
[1] "a1812100bd1dba00c2ed1cd507000b92"

$rev
[1] "1-5406480672da172726810767e7d0ead3"
```

#### Write an xml document WITH a name (uses PUT). The xml is written as xml in couchdb, just wrapped in json, when you get it out it will be as xml.

```ruby
# write the xml
doc3 <- "<top><a/><b/><c><d/><e>bob</e></c></top>"
sofa_writedoc(dbname="sofadb", doc=doc3, docid="somexml")

$ok
[1] TRUE

$id
[1] "somexml"

$rev
[1] "5-493a2080920f9843459326b50ad358a1"

# get the doc back out
sofa_getdoc(dbname="sofadb", docid="somexml")

                                       _id 
                                 "somexml" 
                                      _rev 
      "5-493a2080920f9843459326b50ad358a1" 
                                       xml 
"<top><a/><b/><c><d/><e>bob</e></c></top>" 

# get just the xml out
sofa_getdoc(dbname="sofadb", docid="somexml")[["xml"]]

[1] "<top><a/><b/><c><d/><e>bob</e></c></top>"
```


### Full text search? por sepuesto

#### Install Elasticsearch (on OSX)

+ Download zip or tar file
+ Unzip it: `unzip or untar`
+ Move it: `sudo mv /path/to/elasticsearch-0.20.6 /usr/local`
+ Navigate to /usr/local: `cd /usr/local`
+ Add shortcut: `sudo ln -s elasticsearch-0.20.6 elasticsearch`

#### Install CouchDB River plugin for Elasticsearch

+ Navigate to elastisearch di: `cd elasticsearch`
+ Install it: `bin/plugin -install elasticsearch/elasticsearch-river-couchdb/1.1.0`

#### Start Elasticsearch

+ Navigate to elasticsearch: `cd /usr/local/elasticsearch`
+ Start elasticsearch: `bin/elasticsearch -f`

#### Make call to elasticsearch to start indexing (and always index) your database

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

#### Searching

##### At the cli...

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

##### In R...

```ruby
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

##### Using CouchDB views

```ruby
#### write a view - here letting key be the default of null
sofa_view_put(dbname='alm_couchdb', design_name='almview2', value="doc.baseurl")

$ok
[1] TRUE

$id
[1] "_design/myview4"

$rev
[1] "1-e7c17cff1b96e4595c3781da53e16ad8"
```

```ruby
#### get info on your new view
sofa_view_get(dbname='alm_couchdb', design_name='almview2')

$`_id`
[1] "_design/almview2"

$`_rev`
[1] "1-e7c17cff1b96e4595c3781da53e16ad8"

$views
$views$foo
                                    map 
"function(doc){emit(null,doc.baseurl)}" 
```

```ruby
#### get data using a view
gg <- sofa_view_search(dbname='alm_couchdb', design_name='almview2')

gg[[3]][1:2]

[[1]]
[[1]]$id
[1] "d0d091e25b9a22e503dc1e4e6710d7a2"

[[1]]$key
NULL

[[1]]$value
[1] "http://alm.plos.org/api/v3/articles"


[[2]]
[[2]]$id
[1] "d0d091e25b9a22e503dc1e4e6710e51d"

[[2]]$key
NULL

[[2]]$value
[1] "http://alm.plos.org/api/v3/articles"

```

```ruby
#### delete the view
sofa_view_del(dbname='alm_couchdb', design_name='almview2')

[1] "" # this means it worked
```