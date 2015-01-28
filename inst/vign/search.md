<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{Search}
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
#> [1] "line"
#> 
#> $`_id`
#> [1] "4"
#> 
#> $`_version`
#> [1] 1
#> 
#> $`_score`
#> [1] 1
#> 
#> $`_source`
#> $`_source`$line_id
#> [1] 5
#> 
#> $`_source`$play_name
#> [1] "Henry IV"
#> 
#> $`_source`$speech_number
#> [1] 1
#> 
#> $`_source`$line_number
#> [1] "1.1.2"
#> 
#> $`_source`$speaker
#> [1] "KING HENRY IV"
#> 
#> $`_source`$text_entry
#> [1] "Find we a time for frighted peace to pant,"
```

### Search an index by type


```r
Search(index="shakespeare", type="act")$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "act"
#> 
#> $`_id`
#> [1] "2227"
#> 
#> $`_version`
#> [1] 1
#> 
#> $`_score`
#> [1] 1
#> 
#> $`_source`
#> $`_source`$line_id
#> [1] 2228
#> 
#> $`_source`$play_name
#> [1] "Henry IV"
#> 
#> $`_source`$speech_number
#> [1] 81
#> 
#> $`_source`$line_number
#> [1] ""
#> 
#> $`_source`$speaker
#> [1] "FALSTAFF"
#> 
#> $`_source`$text_entry
#> [1] "ACT IV"
```

### Return certain fields


```r
Search(index="shakespeare", fields=c('play_name','speaker'))$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "line"
#> 
#> $`_id`
#> [1] "4"
#> 
#> $`_version`
#> [1] 1
#> 
#> $`_score`
#> [1] 1
#> 
#> $fields
#> $fields$speaker
#> $fields$speaker[[1]]
#> [1] "KING HENRY IV"
#> 
#> 
#> $fields$play_name
#> $fields$play_name[[1]]
#> [1] "Henry IV"
```

### Sorting


```r
Search(index="shakespeare", type="act", sort="text_entry")$hits$hits[1:2]
```

```
#> [[1]]
#> [[1]]$`_index`
#> [1] "shakespeare"
#> 
#> [[1]]$`_type`
#> [1] "act"
#> 
#> [[1]]$`_id`
#> [1] "2227"
#> 
#> [[1]]$`_version`
#> [1] 1
#> 
#> [[1]]$`_score`
#> NULL
#> 
#> [[1]]$`_source`
#> [[1]]$`_source`$line_id
#> [1] 2228
#> 
#> [[1]]$`_source`$play_name
#> [1] "Henry IV"
#> 
#> [[1]]$`_source`$speech_number
#> [1] 81
#> 
#> [[1]]$`_source`$line_number
#> [1] ""
#> 
#> [[1]]$`_source`$speaker
#> [1] "FALSTAFF"
#> 
#> [[1]]$`_source`$text_entry
#> [1] "ACT IV"
#> 
#> 
#> [[1]]$sort
#> [[1]]$sort[[1]]
#> [1] "act"
#> 
#> 
#> 
#> [[2]]
#> [[2]]$`_index`
#> [1] "shakespeare"
#> 
#> [[2]]$`_type`
#> [1] "act"
#> 
#> [[2]]$`_id`
#> [1] "2633"
#> 
#> [[2]]$`_version`
#> [1] 1
#> 
#> [[2]]$`_score`
#> NULL
#> 
#> [[2]]$`_source`
#> [[2]]$`_source`$line_id
#> [1] 2634
#> 
#> [[2]]$`_source`$play_name
#> [1] "Henry IV"
#> 
#> [[2]]$`_source`$speech_number
#> [1] 9
#> 
#> [[2]]$`_source`$line_number
#> [1] ""
#> 
#> [[2]]$`_source`$speaker
#> [1] "ARCHBISHOP OF YORK"
#> 
#> [[2]]$`_source`$text_entry
#> [1] "ACT V"
#> 
#> 
#> [[2]]$sort
#> [[2]]$sort[[1]]
#> [1] "act"
```


```r
Search(index="shakespeare", type="act", sort="speaker:desc", fields='speaker')$hits$hits[1:2]
```

```
#> [[1]]
#> [[1]]$`_index`
#> [1] "shakespeare"
#> 
#> [[1]]$`_type`
#> [1] "act"
#> 
#> [[1]]$`_id`
#> [1] "2633"
#> 
#> [[1]]$`_version`
#> [1] 1
#> 
#> [[1]]$`_score`
#> NULL
#> 
#> [[1]]$fields
#> [[1]]$fields$speaker
#> [[1]]$fields$speaker[[1]]
#> [1] "ARCHBISHOP OF YORK"
#> 
#> 
#> 
#> [[1]]$sort
#> [[1]]$sort[[1]]
#> [1] "york"
#> 
#> 
#> 
#> [[2]]
#> [[2]]$`_index`
#> [1] "shakespeare"
#> 
#> [[2]]$`_type`
#> [1] "act"
#> 
#> [[2]]$`_id`
#> [1] "4974"
#> 
#> [[2]]$`_version`
#> [1] 1
#> 
#> [[2]]$`_score`
#> NULL
#> 
#> [[2]]$fields
#> [[2]]$fields$speaker
#> [[2]]$fields$speaker[[1]]
#> [1] "VERNON"
#> 
#> 
#> 
#> [[2]]$sort
#> [[2]]$sort[[1]]
#> [1] "vernon"
```

### Paging


```r
Search(index="shakespeare", size=1, from=1, fields='text_entry')$hits
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
#> [1] "9"
#> 
#> $hits[[1]]$`_version`
#> [1] 1
#> 
#> $hits[[1]]$`_score`
#> [1] 1
#> 
#> $hits[[1]]$fields
#> $hits[[1]]$fields$text_entry
#> $hits[[1]]$fields$text_entry[[1]]
#> [1] "Nor more shall trenching war channel her fields,"
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
#> [1] "{\"took\":2,\"timed_out\":false,\"_shards\":{\"total\":5,\"successful\":5,\"failed\":0},\"hits\":{\"total\":34,\"max_score\":1.0,\"hits\":[{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"112\",\"_version\":1,\"_score\":1.0,\"_source\":{\"line_id\":113,\"play_name\":\"Henry IV\",\"speech_number\":10,\"line_number\":\"\",\"speaker\":\"WESTMORELAND\",\"text_entry\":\"SCENE II. London. An apartment of the Princes.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"989\",\"_version\":1,\"_score\":1.0,\"_source\":{\"line_id\":990,\"play_name\":\"Henry IV\",\"speech_number\":22,\"line_number\":\"\",\"speaker\":\"LADY PERCY\",\"text_entry\":\"SCENE IV. The Boars-Head Tavern, Eastcheap.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"2462\",\"_version\":1,\"_score\":1.0,\"_source\":{\"line_id\":2463,\"play_name\":\"Henry IV\",\"speech_number\":21,\"line_number\":\"\",\"speaker\":\"FALSTAFF\",\"text_entry\":\"SCENE III. The rebel camp near Shrewsbury.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"2784\",\"_version\":1,\"_score\":1.0,\"_source\":{\"line_id\":2785,\"play_name\":\"Henry IV\",\"speech_number\":18,\"line_number\":\"\",\"speaker\":\"FALSTAFF\",\"text_entry\":\"SCENE II. The rebel camp.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"3206\",\"_version\":1,\"_score\":1.0,\"_source\":{\"line_id\":3207,\"play_name\":\"Henry VI Part 1\",\"speech_number\":8,\"line_number\":\"\",\"speaker\":\"KING HENRY IV\",\"text_entry\":\"SCENE I. Westminster Abbey.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"4437\",\"_version\":1,\"_score\":1.0,\"_source\":{\"line_id\":4438,\"play_name\":\"Henry VI Part 1\",\"speech_number\":18,\"line_number\":\"\",\"speaker\":\"PLANTAGENET\",\"text_entry\":\"SCENE I. London. The Parliament-house.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"4975\",\"_version\":1,\"_score\":1.0,\"_source\":{\"line_id\":4976,\"play_name\":\"Henry VI Part 1\",\"speech_number\":11,\"line_number\":\"\",\"speaker\":\"VERNON\",\"text_entry\":\"SCENE I. Paris. A hall of state.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"745\",\"_version\":1,\"_score\":1.0,\"_source\":{\"line_id\":746,\"play_name\":\"Henry IV\",\"speech_number\":32,\"line_number\":\"\",\"speaker\":\"GADSHILL\",\"text_entry\":\"SCENE II. The highway, near Gadshill.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"2228\",\"_version\":1,\"_score\":1.0,\"_source\":{\"line_id\":2229,\"play_name\":\"Henry IV\",\"speech_number\":81,\"line_number\":\"\",\"speaker\":\"FALSTAFF\",\"text_entry\":\"SCENE I. The rebel camp near Shrewsbury.\"}},{\"_index\":\"shakespeare\",\"_type\":\"scene\",\"_id\":\"2588\",\"_version\":1,\"_score\":1.0,\"_source\":{\"line_id\":2589,\"play_name\":\"Henry IV\",\"speech_number\":28,\"line_number\":\"\",\"speaker\":\"SIR WALTER BLUNT\",\"text_entry\":\"SCENE IV. York. The ARCHBISHOPS palace.\"}}]}}"
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
aggs <- list(aggs = list(stats = list(terms = list(field = "text_entry"))))
Search(index="shakespeare", body=aggs)$hits$hits[[1]]
```

```
#> $`_index`
#> [1] "shakespeare"
#> 
#> $`_type`
#> [1] "line"
#> 
#> $`_id`
#> [1] "4"
#> 
#> $`_version`
#> [1] 1
#> 
#> $`_score`
#> [1] 1
#> 
#> $`_source`
#> $`_source`$line_id
#> [1] 5
#> 
#> $`_source`$play_name
#> [1] "Henry IV"
#> 
#> $`_source`$speech_number
#> [1] 1
#> 
#> $`_source`$line_number
#> [1] "1.1.2"
#> 
#> $`_source`$speaker
#> [1] "KING HENRY IV"
#> 
#> $`_source`$text_entry
#> [1] "Find we a time for frighted peace to pant,"
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
#> [1] "line"
#> 
#> $`_id`
#> [1] "4"
#> 
#> $`_version`
#> [1] 1
#> 
#> $`_score`
#> [1] 1
#> 
#> $`_source`
#> $`_source`$line_id
#> [1] 5
#> 
#> $`_source`$play_name
#> [1] "Henry IV"
#> 
#> $`_source`$speech_number
#> [1] 1
#> 
#> $`_source`$line_number
#> [1] "1.1.2"
#> 
#> $`_source`$speaker
#> [1] "KING HENRY IV"
#> 
#> $`_source`$text_entry
#> [1] "Find we a time for frighted peace to pant,"
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
#> [1] "line"
#> 
#> $`_id`
#> [1] "4"
#> 
#> $`_version`
#> [1] 1
#> 
#> $`_score`
#> [1] 1
#> 
#> $`_source`
#> $`_source`$line_id
#> [1] 5
#> 
#> $`_source`$play_name
#> [1] "Henry IV"
#> 
#> $`_source`$speech_number
#> [1] 1
#> 
#> $`_source`$line_number
#> [1] "1.1.2"
#> 
#> $`_source`$speaker
#> [1] "KING HENRY IV"
#> 
#> $`_source`$text_entry
#> [1] "Find we a time for frighted peace to pant,"
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
#> [1] -5
#> 
#> [[2]]$doc_count
#> [1] 1
#> 
#> 
#> [[3]]
#> [[3]]$key
#> [1] 25
#> 
#> [[3]]$doc_count
#> [1] 4
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
#>  [1]  6  7  7  7  7  8  9 10  7  8
```

### Fuzzy query

Fuzzy query on numerics


```r
fuzzy <- list(query = list(fuzzy = list(speech_number = 7)))
Search(index="shakespeare", body=fuzzy)$hits$total
```

```
#> [1] 523
```


```r
fuzzy <- list(query = list(fuzzy = list(speech_number = list(value = 7, fuzziness = 4))))
Search(index="shakespeare", body=fuzzy)$hits$total
```

```
#> [1] 1499
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
#> [1] 166
```

With dates


```r
body <- list(query=list(range=list(eventDate=list(gte="2012-01-01", lte="now"))))
Search('gbif', body=body)$hits$total
```

```
#> [1] 899
```


```r
body <- list(query=list(range=list(eventDate=list(gte="2014-01-01", lte="now"))))
Search('gbif', body=body)$hits$total
```

```
#> [1] 685
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
#> [1] "DUSP1 Is a Novel Target for Enhancing Pancreatic Cancer <em>Cell</em> Sensitivity to Gemcitabine"                       
#> [2] "Carbon Ion Radiation Inhibits Glioma and Endothelial <em>Cell</em> Migration Induced by Secreted VEGF"                  
#> [3] "Dynamic Visualization of Dendritic <em>Cell</em>-Antigen Interactions in the Skin Following Transcutaneous Immunization"
```

### Scrolling search - instead of paging


```r
Search('shakespeare', q="a*")$hits$total
```

```
#> [1] 2747
```

```r
res <- Search(index = 'shakespeare', q="a*", scroll="1m")
res <- Search(index = 'shakespeare', q="a*", scroll="1m", search_type = "scan")
length(scroll(scroll_id = res$`_scroll_id`)$hits$hits)
```

```
#> [1] 50
```


```r
res <- Search(index = 'shakespeare', q="a*", scroll="5m", search_type = "scan")
out <- list()
hits <- 1
while(hits != 0){
  res <- scroll(scroll_id = res$`_scroll_id`)
  hits <- length(res$hits$hits)
  if(hits > 0)
    out <- c(out, res$hits$hits)
}
length(out)
```

```
#> [1] 2747
```

Woohoo! Collected all 2747 documents in very little time.
