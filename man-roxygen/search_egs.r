#' @references
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search.html}
#' @details This function name has the "S" capitalized to avoid conflict with the function
#' \code{base::search}. I hate mixing cases, as I think it confuses users, but in this case
#' it seems neccessary.
#' 
#' Note that \code{Search_} is for use with the elastic DSL workflow, in which \code{Search_}
#' accepts is used internally to execute searches, but you can also use it separately if you
#' want.
#' @examples \dontrun{
#' # Search() vs. Search_()
#' ## Use Search() if you aren't using the elastic DSL
#' Search()
#' ## Use Search_() if you are using the DSL
#' index("shakespeare") %>% Search_()
#' 
#' # URI string queries
#' Search(index="shakespeare")
#' Search(index="shakespeare", type="act")
#' Search(index="shakespeare", type="scene")
#' Search(index="shakespeare", type="line")
#'
#' ## Return certain fields
#' Search(index="shakespeare", fields=c('play_name','speaker'))
#'
#' ## sorting
#' Search(index="shakespeare", type="act", sort="text_entry")
#' Search(index="shakespeare", type="act", sort="speaker:desc", fields='speaker')
#' Search(index="shakespeare", type="act",
#'  sort=c("speaker:desc","play_name:asc"), fields=c('speaker','play_name'))
#'
#' ## paging
#' Search(index="shakespeare", size=1, fields='text_entry')$hits$hits
#' Search(index="shakespeare", size=1, from=1, fields='text_entry')$hits$hits
#'
#' ## queries
#' ### Search in all fields
#' Search(index="shakespeare", type="act", q="york")
#'
#' ### Searchin specific fields
#' Search(index="shakespeare", type="act", q="speaker:KING HENRY IV")$hits$total
#'
#' ### Exact phrase search by wrapping in quotes
#' Search(index="shakespeare", type="act", q='speaker:"KING HENRY IV"')$hits$total
#'
#' ### can specify operators between multiple words parenthetically
#' Search(index="shakespeare", type="act", q="speaker:(HENRY OR ARCHBISHOP)")$hits$total
#'
#' ### where the field line_number has no value (or is missing)
#' Search(index="shakespeare", q="_missing_:line_number")$hits$total
#'
#' ### where the field line_number has any non-null value
#' Search(index="shakespeare", q="_exists_:line_number")$hits$total
#'
#' ### wildcards, either * or ?
#' Search(index="shakespeare", q="*ay")$hits$total
#' Search(index="shakespeare", q="m?y")$hits$total
#'
#' ### regular expressions, wrapped in forward slashes
#' Search(index="shakespeare", q="text_entry:/[a-z]/")$hits$total
#'
#' ### fuzziness
#' Search(index="shakespeare", q="text_entry:ma~")$hits$total
#' Search(index="shakespeare", q="text_entry:the~2")$hits$total
#' Search(index="shakespeare", q="text_entry:the~1")$hits$total
#'
#' ### Proximity searches
#' Search(index="shakespeare", q='text_entry:"as hath"~5')$hits$total
#' Search(index="shakespeare", q='text_entry:"as hath"~10')$hits$total
#'
#' ### Ranges, here where line_id value is between 10 and 20
#' Search(index="shakespeare", q="line_id:[10 TO 20]")$hits$total
#'
#' ### Grouping
#' Search(index="shakespeare", q="(hath OR as) AND the")$hits$total
#'
#' # Limit number of hits returned with the size parameter
#' Search(index="shakespeare", size=1)
#'
#' # Give explanation of search in result
#' Search(index="shakespeare", size=1, explain=TRUE)
#'
#' ## terminate query after x documents found
#' ## setting to 1 gives back one document for each shard
#' Search(index="shakespeare", terminate_after=1)
#' ## or set to other number
#' Search(index="shakespeare", terminate_after=2)
#'
#' ## Get version number for each document
#' Search(index="shakespeare", version=TRUE, size=2)
#'
#' ## Get raw data
#' Search(index="shakespeare", type="scene", raw=TRUE)
#'
#' ## Curl debugging
#' library('httr')
#' out <- Search(index="shakespeare", type="line", config=verbose())
#'
#'
#'
#' # Query DSL searches - queries sent in the body of the request
#' ## Pass in as an R list
#'
#' aggs <- list(aggs = list(stats = list(terms = list(field = "text_entry"))))
#' Search(index="shakespeare", body=aggs)
#'
#' ## or pass in as json query with newlines, easy to read
#' aggs <- '{
#'     "aggs": {
#'         "stats" : {
#'             "terms" : {
#'                 "field" : "text_entry"
#'             }
#'         }
#'     }
#' }'
#' Search(index="shakespeare", body=aggs)
#'
#' ## or pass in collapsed json string
#' aggs <- '{"aggs":{"stats":{"terms":{"field":"text_entry"}}}}'
#' Search(index="shakespeare", body=aggs)
#'
#' ## Aggregations
#' ### Histograms
#' aggs <- '{
#'     "aggs": {
#'         "latbuckets" : {
#'            "histogram" : {
#'                "field" : "decimalLatitude",
#'                "interval" : 5
#'            }
#'         }
#'     }
#' }'
#' Search(index="gbif", body=aggs, size=0)
#'
#' ### Histograms w/ more options
#' aggs <- '{
#'     "aggs": {
#'         "latbuckets" : {
#'            "histogram" : {
#'                "field" : "decimalLatitude",
#'                "interval" : 5,
#'                "min_doc_count" : 0,
#'                "extended_bounds" : {
#'                    "min" : -90,
#'                    "max" : 90
#'                }
#'            }
#'         }
#'     }
#' }'
#' Search(index="gbif", body=aggs, size=0)
#'
#' ### Ordering the buckets by their doc_count - ascending:
#' aggs <- '{
#'     "aggs": {
#'         "latbuckets" : {
#'            "histogram" : {
#'                "field" : "decimalLatitude",
#'                "interval" : 5,
#'                "min_doc_count" : 0,
#'                "extended_bounds" : {
#'                    "min" : -90,
#'                    "max" : 90
#'                },
#'                "order" : {
#'                    "_count" : "desc"
#'                }
#'            }
#'         }
#'     }
#' }'
#' out <- Search(index="gbif", body=aggs, size=0)
#' lapply(out$aggregations$latbuckets$buckets, data.frame)
#'
#' ### By default, the buckets are returned as an ordered array. It is also possible to
#' ### request the response as a hash instead keyed by the buckets keys:
#' aggs <- '{
#'     "aggs": {
#'         "latbuckets" : {
#'            "histogram" : {
#'                "field" : "decimalLatitude",
#'                "interval" : 10,
#'                "keyed" : true
#'            }
#'         }
#'     }
#' }'
#' Search(index="gbif", body=aggs, size=0)
#'
#' # match query
#' match <- '{"query": {"match" : {"text_entry" : "Two Gentlemen"}}}'
#' Search(index="shakespeare", body=match)
#'
#' # multi-match (multiple fields that is) query
#' mmatch <- '{"query": {"multi_match" : {"query" : "henry", "fields": ["text_entry","play_name"]}}}'
#' Search(index="shakespeare", body=mmatch)
#'
#' # bool query
#' mmatch <- '{
#'  "query": {
#'    "bool" : {
#'      "must_not" : {
#'        "range" : {
#'          "speech_number" : {
#'            "from" : 1, "to": 5
#' }}}}}}'
#' Search(index="shakespeare", body=mmatch)
#'
#' # Boosting query
#' boost <- '{
#'  "query" : {
#'   "boosting" : {
#'       "positive" : {
#'           "term" : {
#'               "play_name" : "henry"
#'           }
#'       },
#'       "negative" : {
#'           "term" : {
#'               "text_entry" : "thou"
#'           }
#'       },
#'       "negative_boost" : 0.2
#'     }
#'  }
#' }'
#' Search(index="shakespeare", body=mmatch)
#'
#' # Fuzzy query
#' ## fuzzy query on numerics
#' fuzzy <- list(query = list(fuzzy = list(speech_number = 7)))
#' Search(index="shakespeare", body=fuzzy)$hits$total
#' fuzzy <- list(query = list(fuzzy = list(speech_number = list(value = 7, fuzziness = 4))))
#' Search(index="shakespeare", body=fuzzy)$hits$total
#'
#' ### fuzzy query on date/time
#' fuzzy <- list(query = list(fuzzy = list(eventDate = list(value = "2014-01-29T23:00:00.000",
#'    fuzziness = "1d"))))
#' out <- Search(index="gbif", body=fuzzy, fields="eventDate")
#' out$hits$total
#' sapply(out$hits$hits, function(x) x$fields$eventDate) ## sweet!!!
#'
#' # geoshape query
#' ## not working yets
#' geo <- list(query = list(geo_shape = list(location = list(shape = list(type = "envelope",
#'    coordinates = "[[2,10],[10,20]]")))))
#' geo <- '{
#'  "query": {
#'    "geo_shape": {
#'      "location": {
#'        "point": {
#'          "type": "envelope",
#'          "coordinates": [[2,0],[2.93,100]]
#'        }
#'      }
#'    }
#'  }
#' }'
#' Search(index="gbifnewgeo", body=geo)
#'
#' # range query
#' ## with numeric
#' body <- list(query=list(range=list(decimalLongitude=list(gte=1, lte=3))))
#' Search('gbif', body=body)$hits$total
#'
#' body <- list(query=list(range=list(decimalLongitude=list(gte=2.9, lte=10))))
#' Search('gbif', body=body)$hits$total
#'
#' ## with dates
#' body <- list(query=list(range=list(eventDate=list(gte="2012-01-01", lte="now"))))
#' Search('gbif', body=body)$hits$total
#'
#' body <- list(query=list(range=list(eventDate=list(gte="2014-01-01", lte="now"))))
#' Search('gbif', body=body)$hits$total
#'
#' # more like this query (more_like_this can be shortened to mlt)
#' body <- '{
#'  "query": {
#'    "more_like_this": {
#'      "fields": ["abstract","title"],
#'      "like_text": "and then",
#'      "min_term_freq": 1,
#'      "max_query_terms": 12
#'    }
#'  }
#' }'
#' Search('plos', body=body)$hits$total
#'
#' body <- '{
#'  "query": {
#'    "more_like_this": {
#'      "fields": ["abstract","title"],
#'      "like_text": "cell",
#'      "min_term_freq": 1,
#'      "max_query_terms": 12
#'    }
#'  }
#' }'
#' Search('plos', body=body)$hits$total
#'
#' # Highlighting
#' body <- '{
#'  "query": {
#'    "query_string": {
#'      "query" : "cell"
#'    }
#'  },
#'  "highlight": {
#'    "fields": {
#'      "title": {"number_of_fragments": 2}
#'    }
#'  }
#' }'
#' out <- Search('plos', 'article', body=body)
#' out$hits$total
#' sapply(out$hits$hits, function(x) x$highlight$title[[1]])
#'
#' ### Common terms query
#' body <- '{
#'  "query" : {
#'    "common": {
#'       "body": {
#'            "query": "this is",
#'            "cutoff_frequency": 0.01
#'        }
#'      }
#'   }
#' }'
#' Search('shakespeare', 'line', body=body)
#'
#' ## Scrolling search - instead of paging
#' Search('shakespeare', q="a*")$hits$total
#' res <- Search(index = 'shakespeare', q="a*", scroll="1m")
#' res <- Search(index = 'shakespeare', q="a*", scroll="1m", search_type = "scan")
#' scroll(scroll_id = res$`_scroll_id`)
#'
#' res <- Search(index = 'shakespeare', q="a*", scroll="5m", search_type = "scan")
#' out <- list()
#' hits <- 1
#' while(hits != 0){
#'   res <- scroll(scroll_id = res$`_scroll_id`)
#'   hits <- length(res$hits$hits)
#'   if(hits > 0)
#'     out <- c(out, res$hits$hits)
#' }
#'
#'
#'
#' # Using filters
#' ## A bool filter
#' body <- '{
#'  "query":{
#'    "filtered":{
#'      "filter":{
#'         "bool": {
#'            "must_not" : {
#'                "range" : {
#'                    "year" : { "from" : 2011, "to" : 2012 }
#'                }
#'            }
#'          }
#'      }
#'    }
#'  }
#' }'
#' Search('gbif', body = body)$hits$total
#'
#' ## Geo filters - fun!
#' ### Note that filers have many geospatial filter options, but queries have fewer, and
#' ### require a geo_shape mapping
#'
#' body <- '{
#'  "mappings": {
#'    "record": {
#'      "properties": {
#'          "location" : {"type" : "geo_point"}
#'       }
#'    }
#'  }
#' }'
#' index_create(index='gbifgeopoint', body=body)
#' path <- system.file("examples", "gbif_geopoint.json", package = "elastic")
#' docs_bulk(path)
#'
#' ### Points within a bounding box
#' body <- '{
#'  "query":{
#'    "filtered":{
#'      "filter":{
#'         "geo_bounding_box" : {
#'           "location" : {
#'             "top_left" : {
#'               "lat" : 60,
#'               "lon" : 14
#'             },
#'             "bottom_right" : {
#'               "lat" : 40,
#'               "lon" : 1
#'             }
#'           }
#'        }
#'      }
#'    }
#'  }
#' }'
#' out <- Search('gbifgeopoint', body = body)
#' out$hits$total
#' do.call(rbind, lapply(out$hits$hits, function(x) x$`_source`$location))
#'
#' ### Points within distance of a point
#' body <- '{
#'  "query":{
#'    "filtered":{
#'      "filter":{
#'         "geo_distance" : {
#'         "distance" : "200km" ,
#'            "location" : {
#'               "lon" : 4,
#'               "lat" : 50
#'             }
#'          }
#'        }
#'      }
#'    }
#' }'
#' out <- Search('gbifgeopoint', body = body)
#' out$hits$total
#' do.call(rbind, lapply(out$hits$hits, function(x) x$`_source`$location))
#'
#' ### Points within distance range of a point
#' body <- '{
#'  "query":{
#'    "filtered":{
#'      "filter":{
#'         "geo_distance_range" : {
#'           "from" : "200km",
#'           "to" : "400km",
#'           "location" : {
#'               "lon" : 4,
#'               "lat" : 50
#'            }
#'          }
#'        }
#'      }
#'    }
#' }'
#' out <- Search('gbifgeopoint', body = body)
#' out$hits$total
#' do.call(rbind, lapply(out$hits$hits, function(x) x$`_source`$location))
#'
#' ### Points within a polygon
#' body <- '{
#'  "query":{
#'    "filtered":{
#'      "filter":{
#'         "geo_polygon" : {
#'           "location" : {
#'              "points" : [
#'                [80.0, -20.0], [-80.0, -20.0], [-80.0, 60.0], [40.0, 60.0], [80.0, -20.0]
#'              ]
#'            }
#'          }
#'        }
#'      }
#'    }
#' }'
#' out <- Search('gbifgeopoint', body = body)
#' out$hits$total
#' do.call(rbind, lapply(out$hits$hits, function(x) x$`_source`$location))
#'
#' ### Geoshape filters using queries instead of filters
#' #### Get data with geojson type location data loaded first
#' body <- '{
#'  "mappings": {
#'    "record": {
#'      "properties": {
#'          "location" : {"type" : "geo_shape"}
#'       }
#'    }
#'  }
#' }'
#' index_create(index='geoshape', body=body)
#' path <- system.file("examples", "gbif_geoshape.json", package = "elastic")
#' docs_bulk(path)
#'
#' #### Get data with a square envelope, w/ point defining upper left and the other
#' #### defining the lower right
#' body <- '{
#'  "query":{
#'    "geo_shape" : {
#'      "location" : {
#'          "shape" : {
#'            "type": "envelope",
#'             "coordinates": [[-30, 50],[30, 0]]
#'          }
#'        }
#'      }
#'    }
#' }'
#' out <- Search('geoshape', body = body)
#' out$hits$total
#'
#' #### Get data with a circle, w/ point defining center, and radius
#' body <- '{
#'  "query":{
#'    "geo_shape" : {
#'      "location" : {
#'          "shape" : {
#'            "type": "circle",
#'            "coordinates": [-10, 45],
#'            "radius": "2000km"
#'          }
#'        }
#'      }
#'    }
#' }'
#' out <- Search('geoshape', body = body)
#' out$hits$total
#'
#' #### Use a polygon
#' body <- '{
#'  "query":{
#'    "geo_shape" : {
#'      "location" : {
#'          "shape" : {
#'            "type": "polygon",
#'            "coordinates":  [
#'               [ [80.0, -20.0], [-80.0, -20.0], [-80.0, 60.0], [40.0, 60.0], [80.0, -20.0] ]
#'            ]
#'          }
#'        }
#'      }
#'    }
#' }'
#' out <- Search('geoshape', body = body)
#' out$hits$total
#' 
#' ## Boosting query
#' body <- '{
#'  "query":{
#'    "boosting" : {
#'      "positive" : {
#'         "term" : {
#'           "play_name" : "Henry IV"
#'        }
#'      },
#'      "negative" : {
#'         "term" : {
#'           "speaker" : "WESTMORELAND"
#'        }
#'      },
#'      "negative_boost" : 0.01
#'    }
#'  }
#' }'
#' Search('shakespeare', body = body)
#' 
#' body <- '{
#'  "query":{
#'    "common": {
#'      "text_entry": {
#'        "query": "drinks",
#'        "cutoff_frequency": 0.001
#'      }
#'    }
#'  }
#' }'
#' Search('shakespeare', body = body)
#' 
#' }
