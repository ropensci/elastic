<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{elastic DSL}
-->



elastic DSL
======

You can define any query you can do against the Elasticsearch HTTP API with the `Search()` function in this package. However, writing queries like


```r
'{
  "aggs": {
      "stats" : {
          "terms" : {
              "field" : "text_entry"
          }
      }
  }
}'
```

or as a nested list


```r
list(aggs = list(stats = list(terms = list(field = "text_entry"))))
```

Is quite painful. Enter the `elastic` DSL, which is inspired by the Python library [elasticsearch-dsl](https://github.com/elasticsearch/elasticsearch-dsl-py), but steals the general non-standard evaluation workflow from [R's dplyr](https://github.com/hadley/dplyr).

Here's what the workflow looks like:


```r
index("shakespeare") %>%
   bool(must_not = list(term=list(speaker="KING HENRY IV"))) %>%
   range( speech_number == 5, line_id > 3 ) %>%
   Search()
```

Or, if you want to modify something about the search you can add on `Search()` like 


```r
index("shakespeare") %>%
   bool(must_not = list(term=list(speaker="KING HENRY IV"))) %>%
   range( speech_number == 5, line_id > 3 ) %>%
   Search(explain = TRUE)
```

Load the library


```r
library("elastic")
```

## Define object to query on

The `index()` function defines the index you want to query. You can optionally define a type within an index. The function has a nice print method too.


```r
index("shakespeare")
```

```
#> <index> shakespeare 
#>   type: 
#>   mappings: 
#>     line: 
#>       line_id: long 
#>       line_number: string 
#>       play_name: string 
#>       speaker: string 
#>       speech_number: long 
#>       text_entry: string 
#>     scene: 
#>       line_id: long 
#>       line_number: string 
#>       play_name: string 
#>       speaker: string 
#>       speech_number: long 
#>       text_entry: string 
#>     act: 
#>       line_id: long 
#>       line_number: string 
#>       play_name: string 
#>       speaker: string 
#>       speech_number: long 
#>       text_entry: string
```


```r
index("shakespeare", "scene")
```

```
#> <index> shakespeare 
#>   type: scene 
#>   mappings: 
#>     scene: 
#>       line_id: long 
#>       line_number: string 
#>       play_name: string 
#>       speaker: string 
#>       speech_number: long 
#>       text_entry: string
```

## Generate queries

bool query


```r
bool(must_not = list(term=list(speaker="KING HENRY IV")))
```

```
#> $must_not
#> <lazy>
#>   expr: list(term = list(speaker = "KING HENRY IV"))
#>   env:  <environment: R_GlobalEnv>
```

range query


```r
range( speech_number == 5, line_id > 3 )
```

## Put it all together


```r
index("shakespeare") %>%
  bool(must_not = list(term=list(speaker="KING HENRY IV"))) %>%
  range( speech_number == 5, line_id > 3 )
```
