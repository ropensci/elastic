<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{Search}
%\VignetteEncoding{UTF-8}
-->



elastic searching
======

## Load elastic


```r
library("elastic")
```

## The Search function

The main interface to searching documents in your Elasticsearch store is the function `Search()`. I nearly always develop R software using all lowercase, but R has a function called `search()`, and I wanted to avoid collision with that function.

`Search()` is an interface to both the HTTP search API (in which queries are passed in the URI of the request, meaning queries have to be relatively simple), as well as the POST API, or the Query DSL, in which queries are passed in the body of the request (so can be much more complex).

There are a huge amount of ways you can search Elasticsearch documents - this tutorial covers some of them, and highlights the ways in which you interact with the R outputs.


```r
x <- connect()
```

### Search an index


```r
out <- Search(x, index="shakespeare")
out$hits$total
```

```
#> [1] 5000
```


```r
out$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "line"
#> 
#> $`_id`
#> [1] "0"
#> 
#> $`_score`
#> [1] 1
#> 
#> $`_source`
#> $`_source`$line_id
#> [1] 1
#> 
#> $`_source`$play_name
#> [1] "Henry IV"
#> 
#> $`_source`$line_number
#> [1] ""
#> 
#> $`_source`$speaker
#> [1] ""
#> 
#> $`_source`$text_entry
#> [1] "ACT I"
```

### Search an index by type


```r
Search(x, index = "shakespeare", type = "line")$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "line"
#> 
#> $`_id`
#> [1] "0"
#> 
#> $`_score`
#> [1] 1
#> 
#> $`_source`
#> $`_source`$line_id
#> [1] 1
#> 
#> $`_source`$play_name
#> [1] "Henry IV"
#> 
#> $`_source`$line_number
#> [1] ""
#> 
#> $`_source`$speaker
#> [1] ""
#> 
#> $`_source`$text_entry
#> [1] "ACT I"
```

### Return certain fields


```r
Search(x, index = "shakespeare", body = '{
  "_source": ["play_name", "speaker"]
}')$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "line"
#> 
#> $`_id`
#> [1] "0"
#> 
#> $`_score`
#> [1] 1
#> 
#> $`_source`
#> $`_source`$play_name
#> [1] "Henry IV"
#> 
#> $`_source`$speaker
#> [1] ""
```


### Paging


```r
Search(x, index="shakespeare", size=1, from=1)$hits
```

```
#> $total
#> [1] 5000
#> 
#> $max_score
#> [1] 1
#> 
#> $hits
#> $hits[[1]]
#> $hits[[1]]$`_index`
#> [1] "shakespeare"
#> 
#> $hits[[1]]$`_type`
#> [1] "line"
#> 
#> $hits[[1]]$`_id`
#> [1] "14"
#> 
#> $hits[[1]]$`_score`
#> [1] 1
#> 
#> $hits[[1]]$`_source`
#> $hits[[1]]$`_source`$line_id
#> [1] 15
#> 
#> $hits[[1]]$`_source`$play_name
#> [1] "Henry IV"
#> 
#> $hits[[1]]$`_source`$speech_number
#> [1] 1
#> 
#> $hits[[1]]$`_source`$line_number
#> [1] "1.1.12"
#> 
#> $hits[[1]]$`_source`$speaker
#> [1] "KING HENRY IV"
#> 
#> $hits[[1]]$`_source`$text_entry
#> [1] "Did lately meet in the intestine shock"
```

### Queries

Using the `q` parameter you can pass in a query, which gets passed in the URI of the query. This type of query is less powerful than the below query passed in the body of the request, using the `body` parameter.


```r
Search(x, index="shakespeare", type="line", q="speaker:KING HENRY IV")$hits$total
```

```
#> [1] 5000
```

#### More complex queries

Here, query for values from 10 to 20 in the field `line_id`


```r
Search(x, index="shakespeare", q="line_id:[10 TO 20]")$hits$total
```

```
#> [1] 11
```

### Get version number for each document

Version number usually is not returned.


```r
sapply(Search(x, index="shakespeare", version=TRUE, size=2)$hits$hits, "[[", "_version")
```

```
#> [1] 3 4
```

### Get raw data


```r
Search(x, index="shakespeare", type="line", raw=TRUE)
```

```
#> [1] "{\"took\":0,\"timed_out\":false,\"_shards\":{\"total\":5,\"successful\":5,\"skipped\":0,\"failed\":0},\"hits\":{\"total\":5000,\"max_score\":1.0,\"hits\":[{\"_index\":\"shakespeare\",\"_type\":\"line\",\"_id\":\"0\",\"_score\":1.0,\"_source\":{\"line_id\":1,\"play_name\":\"Henry IV\",\"line_number\":\"\",\"speaker\":\"\",\"text_entry\":\"ACT I\"}},{\"_index\":\"shakespeare\",\"_type\":\"line\",\"_id\":\"14\",\"_score\":1.0,\"_source\":{\"line_id\":15,\"play_name\":\"Henry IV\",\"speech_number\":1,\"line_number\":\"1.1.12\",\"speaker\":\"KING HENRY IV\",\"text_entry\":\"Did lately meet in the intestine shock\"}},{\"_index\":\"shakespeare\",\"_type\":\"line\",\"_id\":\"19\",\"_score\":1.0,\"_source\":{\"line_id\":20,\"play_name\":\"Henry IV\",\"speech_number\":1,\"line_number\":\"1.1.17\",\"speaker\":\"KING HENRY IV\",\"text_entry\":\"The edge of war, like an ill-sheathed knife,\"}},{\"_index\":\"shakespeare\",\"_type\":\"line\",\"_id\":\"22\",\"_score\":1.0,\"_source\":{\"line_id\":23,\"play_name\":\"Henry IV\",\"speech_number\":1,\"line_number\":\"1.1.20\",\"speaker\":\"KING HENRY IV\",\"text_entry\":\"Whose soldier now, under whose blessed cross\"}},{\"_index\":\"shakespeare\",\"_type\":\"line\",\"_id\":\"24\",\"_score\":1.0,\"_source\":{\"line_id\":25,\"play_name\":\"Henry IV\",\"speech_number\":1,\"line_number\":\"1.1.22\",\"speaker\":\"KING HENRY IV\",\"text_entry\":\"Forthwith a power of English shall we levy;\"}},{\"_index\":\"shakespeare\",\"_type\":\"line\",\"_id\":\"25\",\"_score\":1.0,\"_source\":{\"line_id\":26,\"play_name\":\"Henry IV\",\"speech_number\":1,\"line_number\":\"1.1.23\",\"speaker\":\"KING HENRY IV\",\"text_entry\":\"Whose arms were moulded in their mothers womb\"}},{\"_index\":\"shakespeare\",\"_type\":\"line\",\"_id\":\"26\",\"_score\":1.0,\"_source\":{\"line_id\":27,\"play_name\":\"Henry IV\",\"speech_number\":1,\"line_number\":\"1.1.24\",\"speaker\":\"KING HENRY IV\",\"text_entry\":\"To chase these pagans in those holy fields\"}},{\"_index\":\"shakespeare\",\"_type\":\"line\",\"_id\":\"29\",\"_score\":1.0,\"_source\":{\"line_id\":30,\"play_name\":\"Henry IV\",\"speech_number\":1,\"line_number\":\"1.1.27\",\"speaker\":\"KING HENRY IV\",\"text_entry\":\"For our advantage on the bitter cross.\"}},{\"_index\":\"shakespeare\",\"_type\":\"line\",\"_id\":\"40\",\"_score\":1.0,\"_source\":{\"line_id\":41,\"play_name\":\"Henry IV\",\"speech_number\":2,\"line_number\":\"1.1.38\",\"speaker\":\"WESTMORELAND\",\"text_entry\":\"Whose worst was, that the noble Mortimer,\"}},{\"_index\":\"shakespeare\",\"_type\":\"line\",\"_id\":\"41\",\"_score\":1.0,\"_source\":{\"line_id\":42,\"play_name\":\"Henry IV\",\"speech_number\":2,\"line_number\":\"1.1.39\",\"speaker\":\"WESTMORELAND\",\"text_entry\":\"Leading the men of Herefordshire to fight\"}}]}}"
```

### Curl debugging

Common options are `verbose=TRUE`, `timeout_ms=1`, `followlocation=TRUE`.


```r
out <- Search(x, index="shakespeare", type="line", verbose = TRUE)
```

### Query DSL searches - queries sent in the body of the request

Pass in as an R list


```r
mapping_create(x, "shakespeare", "line", update_all_types = TRUE, body = '{
   "properties": {
     "text_entry": {
       "type":     "text",
       "fielddata": true
    }
  }
}')
```

```
#> $acknowledged
#> [1] TRUE
```

```r
aggs <- list(aggs = list(stats = list(terms = list(field = "text_entry"))))
Search(x, index="shakespeare", body=aggs)$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "line"
#> 
#> $`_id`
#> [1] "0"
#> 
#> $`_score`
#> [1] 1
#> 
#> $`_source`
#> $`_source`$line_id
#> [1] 1
#> 
#> $`_source`$play_name
#> [1] "Henry IV"
#> 
#> $`_source`$line_number
#> [1] ""
#> 
#> $`_source`$speaker
#> [1] ""
#> 
#> $`_source`$text_entry
#> [1] "ACT I"
```

Or pass in as json query with newlines, easy to read


```r
aggs <- '{
    "aggs": {
        "stats" : {
            "terms" : {
                "field" : "text_entry"
            }
        }
    }
}'
Search(x, index="shakespeare", body=aggs)$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "line"
#> 
#> $`_id`
#> [1] "0"
#> 
#> $`_score`
#> [1] 1
#> 
#> $`_source`
#> $`_source`$line_id
#> [1] 1
#> 
#> $`_source`$play_name
#> [1] "Henry IV"
#> 
#> $`_source`$line_number
#> [1] ""
#> 
#> $`_source`$speaker
#> [1] ""
#> 
#> $`_source`$text_entry
#> [1] "ACT I"
```

Or pass in collapsed json string


```r
aggs <- '{"aggs":{"stats":{"terms":{"field":"text_entry"}}}}'
Search(x, index="shakespeare", body=aggs)$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "line"
#> 
#> $`_id`
#> [1] "0"
#> 
#> $`_score`
#> [1] 1
#> 
#> $`_source`
#> $`_source`$line_id
#> [1] 1
#> 
#> $`_source`$play_name
#> [1] "Henry IV"
#> 
#> $`_source`$line_number
#> [1] ""
#> 
#> $`_source`$speaker
#> [1] ""
#> 
#> $`_source`$text_entry
#> [1] "ACT I"
```

### Aggregations

Histograms


```r
aggs <- '{
    "aggs": {
        "latbuckets" : {
           "histogram" : {
               "field" : "decimalLatitude",
               "interval" : 5
           }
        }
    }
}'
Search(x, index="gbif", body=aggs, size=0)$aggregations$latbuckets$buckets[1:3]
```

```
#> [[1]]
#> [[1]]$key
#> [1] -35
#> 
#> [[1]]$doc_count
#> [1] 1
#> 
#> 
#> [[2]]
#> [[2]]$key
#> [1] -30
#> 
#> [[2]]$doc_count
#> [1] 0
#> 
#> 
#> [[3]]
#> [[3]]$key
#> [1] -25
#> 
#> [[3]]$doc_count
#> [1] 0
```

### A bool query


```r
mmatch <- '{
 "query": {
   "bool" : {
     "must_not" : {
       "range" : {
         "speech_number" : {
           "from" : 1, "to": 5
}}}}}}'
sapply(Search(x, index="shakespeare", body=mmatch)$hits$hits, function(x) x$`_source`$speech_number)
```

```
#> [[1]]
#> NULL
#> 
#> [[2]]
#> [1] 6
#> 
#> [[3]]
#> [1] 7
#> 
#> [[4]]
#> [1] 7
#> 
#> [[5]]
#> [1] 7
#> 
#> [[6]]
#> [1] 8
#> 
#> [[7]]
#> [1] 8
#> 
#> [[8]]
#> [1] 9
#> 
#> [[9]]
#> [1] 9
#> 
#> [[10]]
#> [1] 10
```

### Fuzzy query

Fuzzy query on numerics


```r
fuzzy <- list(query = list(fuzzy = list(text_entry = "arms")))
Search(x, index="shakespeare", body = fuzzy)$hits$total
```

```
#> [1] 49
```


```r
fuzzy <- list(query = list(fuzzy = list(text_entry = list(value = "arms", fuzziness = 4))))
Search(x, index="shakespeare", body=fuzzy)$hits$total
```

```
#> [1] 617
```

### Range query

With numeric


```r
body <- list(query=list(range=list(decimalLongitude=list(gte=1, lte=3))))
Search(x, 'gbif', body=body)$hits$total
```

```
#> [1] 24
```


```r
body <- list(query=list(range=list(decimalLongitude=list(gte=2.9, lte=10))))
Search(x, 'gbif', body=body)$hits$total
```

```
#> [1] 126
```

With dates


```r
body <- list(query=list(range=list(eventDate=list(gte="2012-01-01", lte="now"))))
Search(x, 'gbif', body=body)$hits$total
```

```
#> [1] 301
```


```r
body <- list(query=list(range=list(eventDate=list(gte="2014-01-01", lte="now"))))
Search(x, 'gbif', body=body)$hits$total
```

```
#> [1] 292
```

### More-like-this query (more_like_this can be shortened to mlt)


```r
body <- '{
 "query": {
   "more_like_this": {
     "fields": ["abstract","title"],
     "like": "and then",
     "min_term_freq": 1,
     "max_query_terms": 12
   }
 }
}'
Search(x, 'plos', body=body)$hits$total
```

```
#> [1] 488
```


```r
body <- '{
 "query": {
   "more_like_this": {
     "fields": ["abstract","title"],
     "like": "cell",
     "min_term_freq": 1,
     "max_query_terms": 12
   }
 }
}'
Search(x, 'plos', body=body)$hits$total
```

```
#> [1] 58
```


### Highlighting


```r
body <- '{
 "query": {
   "query_string": {
     "query" : "cell"
   }
 },
 "highlight": {
   "fields": {
     "title": {"number_of_fragments": 2}
   }
 }
}'
out <- Search(x, 'plos', 'article', body=body)
out$hits$total
```

```
#> [1] 58
```


```r
sapply(out$hits$hits, function(x) x$highlight$title[[1]])[8:10]
```

```
#> [1] "Chronic Hypoxia Promotes Pulmonary Artery Endothelial <em>Cell</em> Proliferation through H2O2-Induced 5-Lipoxygenase"  
#> [2] "Dynamic Visualization of Dendritic <em>Cell</em>-Antigen Interactions in the Skin Following Transcutaneous Immunization"
#> [3] "A New Class of Pluripotent Stem <em>Cell</em> Cytotoxic Small Molecules"
```

### Scrolling search - instead of paging


```r
Search(x, 'shakespeare', q="a*")$hits$total
```

```
#> [1] 2747
```

```r
res <- Search(x, index = 'shakespeare', q="a*", time_scroll = "1m")
length(scroll(x, res$`_scroll_id`, time_scroll = "1m")$hits$hits)
```

```
#> [1] 10
```


```r
res <- Search(x, index = 'shakespeare', q = "a*", time_scroll = "5m")
out <- res$hits$hits
hits <- 1
while (hits != 0) {
  res <- scroll(x, res$`_scroll_id`)
  hits <- length(res$hits$hits)
  if (hits > 0)
    out <- c(out, res$hits$hits)
}
length(out)
```

```
#> [1] 2747
```

```r
res$hits$total
```

```
#> [1] 2747
```

Woohoo! Collected all 2747 documents in very little time.
