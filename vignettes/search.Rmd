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

### Search an index


```r
out <- Search(index="shakespeare")
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
#> [1] "act"
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
Search(index = "shakespeare", type = "act")$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "act"
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
Search(index = "shakespeare", body = '{
  "_source": ["play_name", "speaker"]
}')$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "act"
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
Search(index="shakespeare", size=1, from=1)$hits
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
Search(index="shakespeare", type="act", q="speaker:KING HENRY IV")$hits$total
```

```
#> [1] 9
```

#### More complex queries

Here, query for values from 10 to 20 in the field `line_id`


```r
Search(index="shakespeare", q="line_id:[10 TO 20]")$hits$total
```

```
#> [1] 11
```

### Get version number for each document

Version number usually is not returned.


```r
sapply(Search(index="shakespeare", version=TRUE, size=2)$hits$hits, "[[", "_version")
```

```
#> [1] 1 1
```

### Get raw data


```r
Search(index="shakespeare", type="scene", raw=TRUE)
```

```
#> [1] "{\"took\":2,\"timed_out\":false,\"_shards\":{\"total\":5,\"successful\":5,\"skipped\":0,\"failed\":0},\"hits\":{\"total\":34,\"max_score\":1.0,\"hits\":[{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"646\",\"_score\":1.0,\"_source\":{\"line_id\":647,\"play_name\":\"Henry IV\",\"speech_number\":54,\"line_number\":\"\",\"speaker\":\"HOTSPUR\",\"text_entry\":\"SCENE I. Rochester. An inn yard.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"1829\",\"_score\":1.0,\"_source\":{\"line_id\":1830,\"play_name\":\"Henry IV\",\"speech_number\":74,\"line_number\":\"\",\"speaker\":\"MORTIMER\",\"text_entry\":\"SCENE II. London. The palace.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"2588\",\"_score\":1.0,\"_source\":{\"line_id\":2589,\"play_name\":\"Henry IV\",\"speech_number\":28,\"line_number\":\"\",\"speaker\":\"SIR WALTER BLUNT\",\"text_entry\":\"SCENE IV. York. The ARCHBISHOPS palace.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"3156\",\"_score\":1.0,\"_source\":{\"line_id\":3157,\"play_name\":\"Henry IV\",\"speech_number\":37,\"line_number\":\"\",\"speaker\":\"FALSTAFF\",\"text_entry\":\"SCENE V. Another part of the field.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"3870\",\"_score\":1.0,\"_source\":{\"line_id\":3871,\"play_name\":\"Henry VI Part 1\",\"speech_number\":5,\"line_number\":\"\",\"speaker\":\"CHARLES\",\"text_entry\":\"SCENE I. Before Orleans.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"4031\",\"_score\":1.0,\"_source\":{\"line_id\":4032,\"play_name\":\"Henry VI Part 1\",\"speech_number\":12,\"line_number\":\"\",\"speaker\":\"Captain\",\"text_entry\":\"SCENE III. Auvergne. The COUNTESSs castle.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"4294\",\"_score\":1.0,\"_source\":{\"line_id\":4295,\"play_name\":\"Henry VI Part 1\",\"speech_number\":47,\"line_number\":\"\",\"speaker\":\"PLANTAGENET\",\"text_entry\":\"SCENE V. The Tower of London.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"4923\",\"_score\":1.0,\"_source\":{\"line_id\":4924,\"play_name\":\"Henry VI Part 1\",\"speech_number\":24,\"line_number\":\"\",\"speaker\":\"CHARLES\",\"text_entry\":\"SCENE IV. Paris. The palace.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"4975\",\"_score\":1.0,\"_source\":{\"line_id\":4976,\"play_name\":\"Henry VI Part 1\",\"speech_number\":11,\"line_number\":\"\",\"speaker\":\"VERNON\",\"text_entry\":\"SCENE I. Paris. A hall of state.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"324\",\"_score\":1.0,\"_source\":{\"line_id\":325,\"play_name\":\"Henry IV\",\"speech_number\":62,\"line_number\":\"\",\"speaker\":\"PRINCE HENRY\",\"text_entry\":\"SCENE III. London. The palace.\"}}]}}"
```

### Curl debugging

Common options are `verbose()`, `timeout()`, `progress()`, `config(followlocation=TRUE)`.


```r
library('httr')
out <- Search(index="shakespeare", type="line", config=verbose())
```

### Query DSL searches - queries sent in the body of the request

Pass in as an R list


```r
mapping_create("shakespeare", "act", update_all_types = TRUE, body = '{
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
Search(index="shakespeare", body=aggs)$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "act"
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
Search(index="shakespeare", body=aggs)$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "act"
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
Search(index="shakespeare", body=aggs)$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "act"
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
Search(index="gbif", body=aggs, size=0)$aggregations$latbuckets$buckets[1:3]
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
sapply(Search(index="shakespeare", body=mmatch)$hits$hits, function(x) x$`_source`$speech_number)
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
Search(index="shakespeare", body = fuzzy)$hits$total
```

```
#> [1] 49
```


```r
fuzzy <- list(query = list(fuzzy = list(text_entry = list(value = "arms", fuzziness = 4))))
Search(index="shakespeare", body=fuzzy)$hits$total
```

```
#> [1] 617
```

### Range query

With numeric


```r
body <- list(query=list(range=list(decimalLongitude=list(gte=1, lte=3))))
Search('gbif', body=body)$hits$total
```

```
#> [1] 24
```


```r
body <- list(query=list(range=list(decimalLongitude=list(gte=2.9, lte=10))))
Search('gbif', body=body)$hits$total
```

```
#> [1] 126
```

With dates


```r
body <- list(query=list(range=list(eventDate=list(gte="2012-01-01", lte="now"))))
Search('gbif', body=body)$hits$total
```

```
#> [1] 300
```


```r
body <- list(query=list(range=list(eventDate=list(gte="2014-01-01", lte="now"))))
Search('gbif', body=body)$hits$total
```

```
#> [1] 291
```

### More-like-this query (more_like_this can be shortened to mlt)


```r
body <- '{
 "query": {
   "more_like_this": {
     "fields": ["abstract","title"],
     "like_text": "and then",
     "min_term_freq": 1,
     "max_query_terms": 12
   }
 }
}'
Search('plos', body=body)$hits$total
```

```
#> [1] 488
```


```r
body <- '{
 "query": {
   "more_like_this": {
     "fields": ["abstract","title"],
     "like_text": "cell",
     "min_term_freq": 1,
     "max_query_terms": 12
   }
 }
}'
Search('plos', body=body)$hits$total
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
out <- Search('plos', 'article', body=body)
out$hits$total
```

```
#> [1] 58
```


```r
sapply(out$hits$hits, function(x) x$highlight$title[[1]])[8:10]
```

```
#> [[1]]
#> NULL
#> 
#> [[2]]
#> NULL
#> 
#> [[3]]
#> NULL
```

### Scrolling search - instead of paging


```r
Search('shakespeare', q="a*")$hits$total
```

```
#> [1] 2747
```

```r
res <- Search(index = 'shakespeare', q="a*", time_scroll = "1m")
length(scroll(res$`_scroll_id`)$hits$hits)
```

```
#> [1] 10
```


```r
res <- Search(index = 'shakespeare', q = "a*", time_scroll = "5m")
out <- list()
hits <- 1
while (hits != 0) {
  res <- scroll(res$`_scroll_id`)
  hits <- length(res$hits$hits)
  if (hits > 0)
    out <- c(out, res$hits$hits)
}
length(out)
```

```
#> [1] 2737
```

Woohoo! Collected all 2737 documents in very little time.
