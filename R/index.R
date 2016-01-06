#' Index API operations
#'
#' @references
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/indices.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @name index
#'
#' @param index (character) A character vector of index names
#' @param features (character) A character vector of features. One or more of settings, mappings,
#' warmers or aliases
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param ... Curl args passed on to \code{\link[httr]{POST}}, \code{\link[httr]{GET}},
#' \code{\link[httr]{PUT}}, \code{\link[httr]{HEAD}}, or \code{\link[httr]{DELETE}}
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param fields (character) Fields to add.
#' @param metric (character) A character vector of metrics to display. Possible values: "_all",
#' "completion", "docs", "fielddata", "filter_cache", "flush", "get", "id_cache", "indexing",
#' "merge", "percolate", "refresh", "search", "segments", "store", "warmer".
#' @param completion_fields (character) A character vector of fields for completion metric
#' (supports wildcards)
#' @param fielddata_fields (character) A character vector of fields for fielddata metric
#' (supports wildcards)
#' @param groups (character) A character vector of search groups for search statistics.
#' @param level (character) Return stats aggregated on "cluster", "indices" (default) or "shards"
#' @param active_only (logical) Display only those recoveries that are currently on-going.
#' Default: FALSE
#' @param detailed (logical) Whether to display detailed information about shard recovery.
#' Default: FALSE
#' @param max_num_segments (character) The number of segments the index should be merged into.
#' Default: "dynamic"
#' @param only_expunge_deletes (logical) Specify whether the operation should only expunge
#' deleted documents
#' @param flush (logical) Specify whether the index should be flushed after performing the
#' operation. Default: TRUE
#' @param wait_for_merge (logical) Specify whether the request should block until the merge
#' process is finished. Default: TRUE
#' @param wait_for_completion (logical) Should the request wait for the upgrade to complete.
#' Default: FALSE
#'
#' @param text The text on which the analysis should be performed (when request body is not used)
#' @param field Use the analyzer configured for this field (instead of passing the analyzer name)
#' @param analyzer The name of the analyzer to use
#' @param tokenizer The name of the tokenizer to use for the analysis
#' @param filters A character vector of filters to use for the analysis
#' @param char_filters A character vector of character filters to use for the analysis
#'
#' @param force (logical) Whether a flush should be forced even if it is not necessarily needed
#' ie. if no changes will be committed to the index.
#' @param full (logical) If set to TRUE a new index writer is created and settings that have been
#' changed related to the index writer will be refreshed.
#' @param wait_if_ongoing If TRUE, the flush operation will block until the flush can be executed
#' if another flush operation is already executing. The default is false and will cause an
#' exception to be thrown on the shard level if another flush operation is already running.
#' [1.4.0.Beta1]
#'
#' @param filter (logical) Clear filter caches
#' @param filter_keys (character) A vector of keys to clear when using the \code{filter_cache}
#' parameter (default: all)
#' @param fielddata (logical) Clear field data
#' @param query_cache (logical) Clear query caches
#' @param id_cache (logical) Clear ID caches for parent/child
#'
#' @param body Query, either a list or json.
#'
#' @details
#' \bold{index_analyze}:
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-analyze.html}
#' This method can accept a string of text in the body, but this function passes it as a
#' parameter in a GET request to simplify.
#'
#' \bold{index_flush}:
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-flush.html}
#' From the ES website: The flush process of an index basically frees memory from the index by
#' flushing data to the index storage and clearing the internal transaction log. By default,
#' Elasticsearch uses memory heuristics in order to automatically trigger flush operations as
#' required in order to clear memory.
#'
#' \bold{index_status}: The API endpoint for this function was deprecated in
#' Elasticsearch \code{v1.2.0}, and will likely be removed soon. Use \code{\link{index_recovery}}
#' instead.
#' 
#' \bold{index_settings_update}: There are a lot of options you can change with this 
#' function. See 
#' https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html 
#' for all the options.
#'
#' @examples \dontrun{
#' # get information on an index
#' index_get(index='shakespeare')
#' index_get(index='shakespeare', features=c('settings','mappings'))
#' index_get(index='shakespeare', features='aliases')
#' index_get(index='shakespeare', features='warmers')
#'
#' # check for index existence
#' index_exists(index='shakespeare')
#' index_exists(index='plos')
#'
#' # create an index
#' if (index_exists('twitter')) index_delete('twitter')
#' index_create(index='twitter')
#' if (index_exists('things')) index_delete('things')
#' index_create(index='things')
#' if (index_exists('plos')) index_delete('plos')
#' index_create(index='plos')
#' 
#' # re-create an index
#' index_recreate("deer")
#' index_recreate("deer", verbose = FALSE)
#'
#' # delete an index
#' if (index_exists('plos')) index_delete(index='plos')
#'
#' ## with a body
#' body <- '{
#'  "settings" : {
#'   "index" : {
#'     "number_of_shards" : 3,
#'     "number_of_replicas" : 2
#'    }
#'  }
#' }'
#' if (index_exists('alsothat')) index_delete('alsothat')
#' index_create(index='alsothat', body=body)
#'
#' ## with mappings
#' body <- '{
#'  "mappings": {
#'    "record": {
#'      "properties": {
#'        "location" : {"type" : "geo_point"}
#'       }
#'    }
#'  }
#' }'
#' if (!index_exists('gbifnewgeo')) index_create(index='gbifnewgeo', body=body)
#' gbifgeo <- system.file("examples", "gbif_geosmall.json", package = "elastic")
#' docs_bulk(gbifgeo)
#'
#' # close an index
#' index_create('plos')
#' index_close('plos')
#'
#' # open an index
#' index_open('plos')
#'
#' # Get stats on an index
#' index_stats('plos')
#' index_stats(c('plos','gbif'))
#' index_stats(c('plos','gbif'), metric='refresh')
#' index_stats(metric = "indices")
#' index_stats('shakespeare', metric='completion')
#' index_stats('shakespeare', metric='completion', completion_fields = "completion")
#' index_stats('shakespeare', metric='fielddata')
#' index_stats('shakespeare', metric='fielddata', fielddata_fields = "evictions")
#' index_stats('plos', level="indices")
#' index_stats('plos', level="cluster")
#' index_stats('plos', level="shards")
#'
#' # Get segments information that a Lucene index (shard level) is built with
#' index_segments()
#' index_segments('plos')
#' index_segments(c('plos','gbif'))
#'
#' # Get recovery information that provides insight into on-going index shard recoveries
#' index_recovery()
#' index_recovery('plos')
#' index_recovery(c('plos','gbif'))
#' index_recovery("plos", detailed = TRUE)
#' index_recovery("plos", active_only = TRUE)
#'
#' # Optimize an index, or many indices
#' index_optimize('plos')
#' index_optimize(c('plos','gbif'))
#'
#' # Upgrade one or more indices to the latest format. The upgrade process converts any
#' # segments written with previous formats.
#' index_upgrade('plos')
#' index_upgrade(c('plos','gbif'))
#'
#' # Performs the analysis process on a text and return the tokens breakdown of the text.
#' index_analyze(text = 'this is a test', analyzer='standard')
#' index_analyze(text = 'this is a test', analyzer='whitespace')
#' index_analyze(text = 'this is a test', analyzer='stop')
#' index_analyze(text = 'this is a test', tokenizer='keyword', filters='lowercase')
#' index_analyze(text = 'this is a test', tokenizer='keyword', filters='lowercase',
#'    char_filters='html_strip')
#' index_analyze(text = 'this is a test', index = 'plos')
#' index_analyze(text = 'this is a test', index = 'shakespeare')
#' index_analyze(text = 'this is a test', index = 'shakespeare', config=verbose())
#'
#' ## NGram tokenizer
#' body <- '{
#'         "settings" : {
#'              "analysis" : {
#'                  "analyzer" : {
#'                      "my_ngram_analyzer" : {
#'                          "tokenizer" : "my_ngram_tokenizer"
#'                      }
#'                  },
#'                  "tokenizer" : {
#'                      "my_ngram_tokenizer" : {
#'                          "type" : "nGram",
#'                          "min_gram" : "2",
#'                          "max_gram" : "3",
#'                          "token_chars": [ "letter", "digit" ]
#'                      }
#'                  }
#'              }
#'       }
#' }'
#' if(index_exists("shakespeare2")) {
#'    index_delete("shakespeare2")
#' }
#' tokenizer_set(index = "shakespeare2", body=body)
#' index_analyze(text = "art thouh", index = "shakespeare2", analyzer='my_ngram_analyzer')
#'
#' # Explicitly flush one or more indices.
#' index_flush(index = "plos")
#' index_flush(index = "shakespeare")
#' index_flush(index = c("plos","shakespeare"))
#' index_flush(index = "plos", wait_if_ongoing = TRUE)
#' library('httr')
#' index_flush(index = "plos", config=verbose())
#'
#' # Clear either all caches or specific cached associated with one ore more indices.
#' index_clear_cache()
#' index_clear_cache(index = "plos")
#' index_clear_cache(index = "shakespeare")
#' index_clear_cache(index = c("plos","shakespeare"))
#' index_clear_cache(filter = TRUE)
#' library('httr')
#' index_clear_cache(config=verbose())
#'
#' # Index settings
#' ## get settings
#' index_settings()
#' index_settings("_all")
#' index_settings('gbif')
#' index_settings(c('gbif','plos'))
#' index_settings('*s')
#' ## update settings
#' if (index_exists('foobar')) index_delete('foobar')
#' index_create("foobar")
#' settings <- list(index = list(number_of_replicas = 4))
#' index_settings_update("foobar", body = settings)
#' index_get("foobar")$foobar$settings
#' }
NULL

#' @export
#' @rdname index
index_get <- function(index=NULL, features=NULL, raw=FALSE, verbose=TRUE, ...) {
  stop_es_version(120, "index_get")
  index_GET(index, features, raw, ...)
}

#' @export
#' @rdname index
index_exists <- function(index, ...) {
  checkconn()
  url <- file.path(make_url(es_get_auth()), esc(index))
  res <- HEAD(url, ..., make_up())
  if (res$status_code == 200) TRUE else FALSE
}

#' @export
#' @rdname index
index_delete <- function(index, raw=FALSE, verbose=TRUE, ...) {
  checkconn()
  url <- paste0(make_url(es_get_auth()), "/", esc(index))
  out <- DELETE(url, make_up(), ...)
  if (verbose) message(URLdecode(out$url))
  geterror(out)
  tt <- structure(content(out, as = "text"), class = "index_delete")
  if (raw) { tt } else { es_parse(tt) }
}

#' @export
#' @rdname index
index_create <- function(index=NULL, body=NULL, raw=FALSE, verbose=TRUE, ...) {
  checkconn()
  url <- make_url(es_get_auth())
  out <- PUT(paste0(url, "/", esc(index)), body = body, make_up(), ...)
  geterror(out)
  if (verbose) message(URLdecode(out$url))
  tt <- content(out, as = "text")
  if (raw) tt else jsonlite::fromJSON(tt, FALSE)
}

#' @export
#' @rdname index
index_recreate <- function(index=NULL, body=NULL, raw=FALSE, verbose=TRUE, ...) {
  checkconn()
  if (index_exists(index)) {
    if (verbose) message("deleting ", index)
    index_delete(index, verbose = verbose)
  }
  if (verbose) message("creating ", index)
  index_create(index=index, body=body, raw=raw, verbose=verbose, ...)
}

#' @export
#' @rdname index
index_close <- function(index, ...) {
  close_open(index, "_close", ...)
}

#' @export
#' @rdname index
index_open <- function(index, ...) {
  close_open(index, "_open", ...)
}

#' @export
#' @rdname index
index_stats <- function(index=NULL, metric=NULL, completion_fields=NULL, fielddata_fields=NULL,
  fields=NULL, groups=NULL, level='indices', ...) {
  url <- make_url(es_get_auth())
  url <- if (is.null(index)) file.path(url, "_stats") else file.path(url, esc(cl(index)), "_stats")
  url <- if (!is.null(metric)) file.path(url, cl(metric)) else url
  args <- ec(list(completion_fields=completion_fields, fielddata_fields=fielddata_fields,
                  fields=fields, groups=groups, level=level))
  es_GET_(url, args, ...)
}

#' @export
#' @rdname index
index_settings <- function(index="_all", ...) {
  url <- make_url(es_get_auth())
  url <- if(is.null(index) || index == "_all") file.path(url, "_settings") else file.path(url, esc(cl(index)), "_settings")
  es_GET_(url, ...)
}

#' @export
#' @rdname index
index_settings_update <- function(index=NULL, body, ...) {
  url <- make_url(es_get_auth())
  url <- if (is.null(index)) file.path(url, "_settings") else file.path(url, esc(cl(index)), "_settings")
  body <- check_inputs(body)
  tt <- PUT(url, make_up(), ..., body = body)
  geterror(tt)
  res <- content(tt, as = "text")
  jsonlite::fromJSON(res)
}

#' @export
#' @rdname index
index_segments <- function(index = NULL, ...) es_GET_wrap1(index, "_segments", ...)

#' @export
#' @rdname index
index_recovery <- function(index = NULL, detailed = FALSE, active_only = FALSE, ...){
  stop_es_version(110, "index_recovery")
  args <- ec(list(detailed = as_log(detailed), active_only = as_log(active_only)))
  es_GET_wrap1(index, "_recovery", args, ...)
}

#' @export
#' @rdname index
index_optimize <- function(index = NULL, max_num_segments = NULL, only_expunge_deletes = FALSE,
  flush = TRUE, wait_for_merge = TRUE, ...) {
  args <- ec(list(max_num_segments = max_num_segments,
                  only_expunge_deletes = as_log(only_expunge_deletes),
                  flush = as_log(flush),
                  wait_for_merge = as_log(wait_for_merge)
  ))
  es_POST_(index, "_optimize", args, ...)
}

#' @export
#' @rdname index
index_upgrade <- function(index = NULL, wait_for_completion = FALSE, ...) {
  stop_es_version(120, "index_get")
  args <- ec(list(wait_for_completion = as_log(wait_for_completion)))
  es_POST_(index, "_upgrade", args, ...)
}

#' @export
#' @rdname index
index_analyze <- function(text=NULL, field=NULL, index=NULL, analyzer=NULL, tokenizer=NULL,
                          filters=NULL, char_filters=NULL, body=list(), ...) {
  url <- make_url(es_get_auth())
  if(!is.null(index))
    url <- sprintf("%s/%s/_analyze", url, esc(cl(index)))
  else
    url <- sprintf("%s/_analyze", url)
  args <- ec(list(text=text, analyzer=analyzer, tokenizer=tokenizer, filters=filters,
                  char_filters=char_filters, field=field))
  analyze_POST(url, args, body, ...)$tokens
}

#' @export
#' @rdname index
index_flush <- function(index=NULL, force=FALSE, full=FALSE, wait_if_ongoing=FALSE, ...) {
  url <- make_url(es_get_auth())
  if(!is.null(index))
    url <- sprintf("%s/%s/_flush", url, esc(cl(index)))
  else
    url <- sprintf("%s/_flush", url)
  args <- ec(list(force=as_log(force), full=as_log(full), wait_if_ongoing=as_log(wait_if_ongoing)))
  cc_POST(url, args, ...)
}

#' @export
#' @rdname index
index_clear_cache <- function(index=NULL, filter=FALSE, filter_keys=NULL, fielddata=FALSE,
                              query_cache=FALSE, id_cache=FALSE, ...) {
  url <- make_url(es_get_auth())
  if(!is.null(index))
    url <- sprintf("%s/%s/_cache/clear", url, esc(cl(index)))
  else
    url <- sprintf("%s/_cache/clear", url)
  args <- ec(list(filter=as_log(filter), filter_keys=filter_keys, fielddata=as_log(fielddata),
                  query_cache=as_log(query_cache), id_cache=as_log(id_cache)))
  cc_POST(url, args, ...)
}

close_open <- function(index, which, ...){
  checkconn()
  url <- make_url(es_get_auth())
  url <- sprintf("%s/%s/%s", url, esc(index), which)
  out <- POST(url, make_up(), ...)
  # stop_for_status(out)
  geterror(out)
  content(out)
}

es_GET_wrap1 <- function(index, which, args=NULL, ...){
  url <- make_url(es_get_auth())
  url <- if(is.null(index)) file.path(url, which) else file.path(url, esc(cl(index)), which)
  es_GET_(url, args, ...)
}

es_POST_ <- function(index, which, args=NULL, ...){
  checkconn()
  url <- make_url(es_get_auth())
  url <- if(is.null(index)) file.path(url, which) else file.path(url, esc(cl(index)), which)
  tt <- POST(url, query=args, make_up(), ...)
  if(tt$status_code > 202) stop(content(tt)$error)
  jsonlite::fromJSON(content(tt, "text"), FALSE)
}

e_url <- function(x) paste0(x$base, ":", x$port)

analyze_GET <- function(url, args = NULL, ...){
  checkconn()
  out <- GET(url, query=args, make_up(), ...)
  stop_for_status(out)
  tt <- content(out, as = "text")
  jsonlite::fromJSON(tt)
}

analyze_POST <- function(url, args = NULL, body, ...){
  checkconn()
  body <- check_inputs(body)
  out <- POST(url, query=args, body=body, make_up(), ...)
  stop_for_status(out)
  tt <- content(out, as = "text")
  jsonlite::fromJSON(tt)
}

cc_POST <- function(url, args = NULL, ...){
  checkconn()
  tt <- POST(url, body=args, encode = "json", make_up(), ...)
  if(tt$status_code > 202) geterror(tt)
  res <- content(tt, as = "text")
  jsonlite::fromJSON(res, FALSE)
}
