#' Index API operations
#'
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/indices.html>
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @name index
#'
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index (character) A character vector of index names
#' @param features (character) A single feature. One of settings, mappings, or 
#' aliases
#' @param raw If `TRUE` (default), data is parsed to list. If FALSE, then raw JSON.
#' @param ... Curl args passed on to [crul::HttpClient]
#' @param verbose If `TRUE` (default) the url call used printed to console.
#' @param fields (character) Fields to add.
#' @param metric (character) A character vector of metrics to display. Possible 
#' values: "_all", "completion", "docs", "fielddata", "filter_cache", "flush", 
#' "get", "id_cache", "indexing", "merge", "percolate", "refresh", "search", 
#' "segments", "store", "warmer".
#' @param completion_fields (character) A character vector of fields for completion metric
#' (supports wildcards)
#' @param fielddata_fields (character) A character vector of fields for fielddata metric
#' (supports wildcards)
#' @param groups (character) A character vector of search groups for search statistics.
#' @param level (character) Return stats aggregated on "cluster", "indices" (default) or "shards"
#' @param active_only (logical) Display only those recoveries that are currently on-going.
#' Default: `FALSE`
#' @param detailed (logical) Whether to display detailed information about shard recovery.
#' Default: `FALSE`
#' @param max_num_segments (character) The number of segments the index should be merged into.
#' Default: "dynamic"
#' @param only_expunge_deletes (logical) Specify whether the operation should only expunge
#' deleted documents
#' @param flush (logical) Specify whether the index should be flushed after performing the
#' operation. Default: `TRUE`
#' @param wait_for_merge (logical) Specify whether the request should block until the merge
#' process is finished. Default: `TRUE`
#' @param wait_for_completion (logical) Should the request wait for the upgrade to complete.
#' Default: `FALSE`
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
#'
#' @param filter (logical) Clear filter caches
#' @param filter_keys (character) A vector of keys to clear when using the `filter_cache`
#' parameter (default: all)
#' @param fielddata (logical) Clear field data
#' @param query_cache (logical) Clear query caches
#' @param id_cache (logical) Clear ID caches for parent/child
#'
#' @param body Query, either a list or json.
#'
#' @details
#' **index_analyze**:
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-analyze.html}
#' This method can accept a string of text in the body, but this function passes it as a
#' parameter in a GET request to simplify.
#'
#' **index_flush**:
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-flush.html}
#' From the ES website: The flush process of an index basically frees memory from the index by
#' flushing data to the index storage and clearing the internal transaction log. By default,
#' Elasticsearch uses memory heuristics in order to automatically trigger flush operations as
#' required in order to clear memory.
#'
#' **index_status**: The API endpoint for this function was deprecated in
#' Elasticsearch `v1.2.0`, and will likely be removed soon. Use [index_recovery()]
#' instead.
#'
#' **index_settings_update**: There are a lot of options you can change with this
#' function. See
#' https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html
#' for all the options.
#' 
#' **index settings**: See
#' https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html
#' for the *static* and *dynamic* settings you can set on indices.
#'
#' @examples \dontrun{
#' # connection setup
#' (x <- connect())
#' 
#' # get information on an index
#' index_get(x, index='shakespeare')
#' ## this one is the same as running index_settings('shakespeare')
#' index_get(x, index='shakespeare', features='settings')
#' index_get(x, index='shakespeare', features='mappings')
#' index_get(x, index='shakespeare', features='alias')
#'
#' # check for index existence
#' index_exists(x, index='shakespeare')
#' index_exists(x, index='plos')
#'
#' # create an index
#' if (index_exists(x, 'twitter')) index_delete(x, 'twitter')
#' index_create(x, index='twitter')
#' if (index_exists(x, 'things')) index_delete(x, 'things')
#' index_create(x, index='things')
#' if (index_exists(x, 'plos')) index_delete(x, 'plos')
#' index_create(x, index='plos')
#'
#' # re-create an index
#' index_recreate(x, "deer")
#' index_recreate(x, "deer", verbose = FALSE)
#'
#' # delete an index
#' if (index_exists(x, 'plos')) index_delete(x, index='plos')
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
#' if (index_exists(x, 'alsothat')) index_delete(x, 'alsothat')
#' index_create(x, index='alsothat', body = body)
#' ## with read only
#' body <- '{
#'  "settings" : {
#'   "index" : {
#'     "blocks" : {
#'       "read_only" : true
#'     }
#'    }
#'  }
#' }'
#' # index_create(x, index='myindex', body = body)
#' # then this delete call should fail with something like:
#' ## > Error: 403 - blocked by: [FORBIDDEN/5/index read-only (api)]
#' # index_delete(x, index='myindex')
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
#' if (!index_exists(x, 'gbifnewgeo')) index_create(x, index='gbifnewgeo', body=body)
#' gbifgeo <- system.file("examples", "gbif_geosmall.json", package = "elastic")
#' docs_bulk(x, gbifgeo)
#'
#' # close an index
#' index_create(x, 'plos')
#' index_close(x, 'plos')
#'
#' # open an index
#' index_open(x, 'plos')
#'
#' # Get stats on an index
#' index_stats(x, 'plos')
#' index_stats(x, c('plos','gbif'))
#' index_stats(x, c('plos','gbif'), metric='refresh')
#' index_stats(x, metric = "indexing")
#' index_stats(x, 'shakespeare', metric='completion')
#' index_stats(x, 'shakespeare', metric='completion', completion_fields = "completion")
#' index_stats(x, 'shakespeare', metric='fielddata')
#' index_stats(x, 'shakespeare', metric='fielddata', fielddata_fields = "evictions")
#' index_stats(x, 'plos', level="indices")
#' index_stats(x, 'plos', level="cluster")
#' index_stats(x, 'plos', level="shards")
#'
#' # Get segments information that a Lucene index (shard level) is built with
#' index_segments(x)
#' index_segments(x, 'plos')
#' index_segments(x, c('plos','gbif'))
#'
#' # Get recovery information that provides insight into on-going index shard recoveries
#' index_recovery(x)
#' index_recovery(x, 'plos')
#' index_recovery(x, c('plos','gbif'))
#' index_recovery(x, "plos", detailed = TRUE)
#' index_recovery(x, "plos", active_only = TRUE)
#'
#' # Optimize an index, or many indices
#' if (x$es_ver() < 500) {
#'   ### ES < v5 - use optimize
#'   index_optimize(x, 'plos')
#'   index_optimize(x, c('plos','gbif'))
#'   index_optimize(x, 'plos')
#' } else {
#'   ### ES > v5 - use forcemerge
#'   index_forcemerge(x, 'plos')
#' }
#'
#' # Upgrade one or more indices to the latest format. The upgrade process converts any
#' # segments written with previous formats.
#' if (x$es_ver() < 500) {
#'   index_upgrade(x, 'plos')
#'   index_upgrade(x, c('plos','gbif'))
#' }
#'
#' # Performs the analysis process on a text and return the tokens breakdown 
#' # of the text
#' index_analyze(x, text = 'this is a test', analyzer='standard')
#' index_analyze(x, text = 'this is a test', analyzer='whitespace')
#' index_analyze(x, text = 'this is a test', analyzer='stop')
#' index_analyze(x, text = 'this is a test', tokenizer='keyword', 
#'   filters='lowercase')
#' index_analyze(x, text = 'this is a test', tokenizer='keyword', 
#'   filters='lowercase', char_filters='html_strip')
#' index_analyze(x, text = 'this is a test', index = 'plos', 
#'   analyzer="standard")
#' index_analyze(x, text = 'this is a test', index = 'shakespeare', 
#'   analyzer="standard")
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
#' if (index_exists(x, "shakespeare2")) index_delete(x, "shakespeare2")
#' tokenizer_set(x, index = "shakespeare2", body=body)
#' index_analyze(x, text = "art thouh", index = "shakespeare2", 
#'   analyzer='my_ngram_analyzer')
#'
#' # Explicitly flush one or more indices.
#' index_flush(x, index = "plos")
#' index_flush(x, index = "shakespeare")
#' index_flush(x, index = c("plos","shakespeare"))
#' index_flush(x, index = "plos", wait_if_ongoing = TRUE)
#' index_flush(x, index = "plos", verbose = TRUE)
#'
#' # Clear either all caches or specific cached associated with one ore more indices.
#' index_clear_cache(x)
#' index_clear_cache(x, index = "plos")
#' index_clear_cache(x, index = "shakespeare")
#' index_clear_cache(x, index = c("plos","shakespeare"))
#' index_clear_cache(x, filter = TRUE)
#'
#' # Index settings
#' ## get settings
#' index_settings(x)
#' index_settings(x, "_all")
#' index_settings(x, 'gbif')
#' index_settings(x, c('gbif','plos'))
#' index_settings(x, '*s')
#' ## update settings
#' if (index_exists(x, 'foobar')) index_delete(x, 'foobar')
#' index_create(x, "foobar")
#' settings <- list(index = list(number_of_replicas = 4))
#' index_settings_update(x, "foobar", body = settings)
#' index_get(x, "foobar")$foobar$settings
#' }
NULL

#' @export
#' @rdname index
index_get <- function(conn, index=NULL, features=NULL, raw=FALSE, verbose=TRUE, ...) {
  is_conn(conn)
  conn$stop_es_version(120, "index_get")
  if (length(features) > 1) stop("'features' must be length 1")
  index_GET(conn, index, features, raw, ...)
}

#' @export
#' @rdname index
index_exists <- function(conn, index, ...) {
  is_conn(conn)
  url <- file.path(conn$make_url(), esc(index))
  res <- conn$make_conn(url, ...)$head()
  if (res$status_code == 200) TRUE else FALSE
}

#' @export
#' @rdname index
index_delete <- function(conn, index, raw=FALSE, verbose=TRUE, ...) {
  is_conn(conn)
  url <- paste0(conn$make_url(), "/", esc(index))
  out <- conn$make_conn(url, ...)$delete()
  if (verbose) message(URLdecode(out$url))
  geterror(conn, out)
  tt <- structure(out$parse('UTF-8'), class = "index_delete")
  if (raw) tt else es_parse(tt)
}

#' @export
#' @rdname index
index_create <- function(conn, index=NULL, body=NULL, raw=FALSE, verbose=TRUE, ...) {
  is_conn(conn)
  url <- conn$make_url()
  es_PUT(conn, paste0(url, "/", esc(index)), body = body, ...)
}

#' @export
#' @rdname index
index_recreate <- function(conn, index=NULL, body=NULL, raw=FALSE, verbose=TRUE, 
                           ...) {
  is_conn(conn)
  if (index_exists(conn, index, ...)) {
    if (verbose) message("deleting ", index)
    index_delete(conn, index, verbose = verbose, ...)
  }
  if (verbose) message("creating ", index)
  index_create(conn, index = index, body = body, raw = raw, verbose = verbose, ...)
}

#' @export
#' @rdname index
index_close <- function(conn, index, ...) {
  is_conn(conn)
  close_open(conn, index, "_close", ...)
}

#' @export
#' @rdname index
index_open <- function(conn, index, ...) {
  is_conn(conn)
  close_open(conn, index, "_open", ...)
}

#' @export
#' @rdname index
index_stats <- function(conn, index=NULL, metric=NULL, completion_fields=NULL, 
                        fielddata_fields=NULL, fields=NULL, groups=NULL, 
                        level='indices', ...) {
  is_conn(conn)
  url <- conn$make_url()
  url <- if (is.null(index)) {
    file.path(url, "_stats") 
  } else {
    file.path(url, esc(cl(index)), "_stats")
  }
  url <- if (!is.null(metric)) file.path(url, cl(metric)) else url
  args <- ec(list(completion_fields = completion_fields, 
                  fielddata_fields = fielddata_fields,
                  fields = fields, groups = groups, level = level))
  es_GET_(conn, url, args, ...)
}

#' @export
#' @rdname index
index_settings <- function(conn, index="_all", ...) {
  is_conn(conn)
  url <- conn$make_url()
  url <- if (is.null(index) || index == "_all") {
    file.path(url, "_settings")
  } else {
    file.path(url, esc(cl(index)), "_settings")
  }
  es_GET_(conn, url, ...)
}

#' @export
#' @rdname index
index_settings_update <- function(conn, index=NULL, body, ...) {
  is_conn(conn)
  url <- conn$make_url()
  url <- if (is.null(index)) {
    file.path(url, "_settings") 
  } else {
    file.path(url, esc(cl(index)), "_settings")
  }
  body <- check_inputs(body)
  es_PUT(conn, url, body = body, ...)
}

#' @export
#' @rdname index
index_segments <- function(conn, index = NULL, ...) {
  is_conn(conn)
  es_GET_wrap1(conn, index, "_segments", ...)
}

#' @export
#' @rdname index
index_recovery <- function(conn, index = NULL, detailed = FALSE, active_only = FALSE, 
                           ...) {
  is_conn(conn)
  conn$stop_es_version(110, "index_recovery")
  args <- ec(list(detailed = as_log(detailed), 
                  active_only = as_log(active_only)))
  es_GET_wrap1(conn, index, "_recovery", args, ...)
}

#' @export
#' @rdname index
index_optimize <- function(conn, index = NULL, max_num_segments = NULL, 
  only_expunge_deletes = FALSE,
  flush = TRUE, wait_for_merge = TRUE, ...) {
  
  is_conn(conn)
  if (conn$es_ver() >= 500) {
    stop("optimize is gone in ES >= v5, see ?index_forcemerge")
  }
  args <- ec(list(max_num_segments = max_num_segments,
                  only_expunge_deletes = as_log(only_expunge_deletes),
                  flush = as_log(flush),
                  wait_for_merge = as_log(wait_for_merge)
  ))
  es_POST_(conn, index, which = "_optimize", args, ...)
}

#' @export
#' @rdname index
index_forcemerge <- function(conn, index = NULL, max_num_segments = NULL, 
                           only_expunge_deletes = FALSE, flush = TRUE, ...) {
  
  is_conn(conn)
  if (conn$es_ver() < 500) {
    stop("forcemerge is only in ES >= v5, see ?index_optimize")
  }
  args <- ec(list(
    max_num_segments = max_num_segments,
    only_expunge_deletes = as_log(only_expunge_deletes),
    flush = as_log(flush)
  ))
  es_POST_(conn, index, which = "_forcemerge", args, ...)
}

#' @export
#' @rdname index
index_upgrade <- function(conn, index = NULL, wait_for_completion = FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(120, "index_get")
  if (conn$es_ver() >= 500) {
    stop("upgrade is removed in ES >= v5, see
https://www.elastic.co/guide/en/elasticsearch/reference/current/reindex-upgrade.html")
  }
  args <- ec(list(wait_for_completion = as_log(wait_for_completion)))
  es_POST_(conn, index, "_upgrade", args, ...)
}

#' @export
#' @rdname index
index_analyze <- function(conn, text=NULL, field=NULL, index=NULL, analyzer=NULL, 
                          tokenizer=NULL, filters=NULL, char_filters=NULL, 
                          body=list(), ...) {
  is_conn(conn)
  url <- conn$make_url()
  if (!is.null(index)) {
    url <- sprintf("%s/%s/_analyze", url, esc(cl(index)))
  } else {
    url <- sprintf("%s/_analyze", url)
  }
  
  if (conn$es_ver() >= 500) {
    body <- ec(list(text = text, analyzer = analyzer, tokenizer = tokenizer, 
                 filter = I(filters), char_filter = I(char_filters), 
                 field = field))
    args <- list()
  } else {
    body <- list()
    args <- ec(list(text = text, analyzer = analyzer, tokenizer = tokenizer, 
                    filters = I(filters), char_filters = I(char_filters), 
                    field = field))
  }
  
  analyze_POST(conn, url, args, body, ...)$tokens
}

#' @export
#' @rdname index
index_flush <- function(conn, index=NULL, force=FALSE, full=FALSE, 
                        wait_if_ongoing=FALSE, ...) {
  
  is_conn(conn)
  url <- conn$make_url()
  if (!is.null(index)) {
    url <- sprintf("%s/%s/_flush", url, esc(cl(index)))
  } else {
    url <- sprintf("%s/_flush", url)
  }
  args <- ec(list(force = as_log(force), full = as_log(full), 
                  wait_if_ongoing = as_log(wait_if_ongoing)))
  cc_POST(conn, url, args, ...)
}

#' @export
#' @rdname index
index_clear_cache <- function(conn, index=NULL, filter=FALSE, filter_keys=NULL, 
                              fielddata=FALSE, query_cache=FALSE, 
                              id_cache=FALSE, ...) {

  is_conn(conn)
  url <- conn$make_url()
  if (!is.null(index)) {
    url <- sprintf("%s/%s/_cache/clear", url, esc(cl(index)))
  } else {
    url <- sprintf("%s/_cache/clear", url)
  }
  args <- ec(list(filter = as_log(filter), filter_keys = filter_keys, 
                  fielddata = as_log(fielddata), 
                  query_cache = as_log(query_cache), 
                  id_cache = as_log(id_cache)))
  cc_POST(conn, url, args, ...)
}



###### HELPERS
close_open <- function(conn, index, which, ...) {
  url <- conn$make_url()
  url <- sprintf("%s/%s/%s", url, esc(index), which)
  out <- conn$make_conn(url, ...)$post()
  geterror(conn, out)
  jsonlite::fromJSON(out$parse("UTF-8"), FALSE)
}

es_GET_wrap1 <- function(conn, index, which, args=NULL, ...) {
  url <- conn$make_url()
  url <- if (is.null(index)) {
    file.path(url, which) 
  } else {
    file.path(url, esc(cl(index)), which)
  }
  es_GET_(conn, url, args, ...)
}

es_POST_ <- function(conn, index, which, args=NULL, ...) {
  url <- conn$make_url()
  url <- if (is.null(index)) {
    file.path(url, which) 
  } else {
    file.path(url, esc(cl(index)), which)
  }
  tt <- conn$make_conn(url, ...)$post(query = args)
  geterror(conn, tt)
  jsonlite::fromJSON(tt$parse('UTF-8'), FALSE)
}

analyze_POST <- function(conn, url, args = NULL, body, ...) {
  body <- check_inputs(body)
  out <- conn$make_conn(url, json_type(), ...)$post(query = args, body = body)
  geterror(conn, out)
  jsonlite::fromJSON(out$parse("UTF-8"))
}

cc_POST <- function(conn, url, args = NULL, ...) {
  tt <- conn$make_conn(url, ...)$post(body = args, encode = "json")
  if (tt$status_code > 202) geterror(conn, tt)
  jsonlite::fromJSON(res <- tt$parse("UTF-8"), FALSE)
}
