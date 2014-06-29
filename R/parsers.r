#' Parse raw data from es_get, es_mget, or es_search.
#'
#' @import assertthat
#' @importFrom rjson fromJSON
#' @param input Output from solr_facet
#' @param parsetype One of 'list' or 'df' (data.frame). Only list possible for now.
#' @param verbose Print messages or not (default: FALSE).
#' @details This is the parser used internally in es_get, es_mget, and es_search,
#' but if you output raw data from es_* functions using raw=TRUE, then you can use this
#' function to parse that data (a es_* S3 object) after the fact to a list of
#' data.frame's for easier consumption.
#' @export
es_parse <- function(input, parsetype, verbose){
  UseMethod("es_parse")
}

#' @method es_parse elastic_get
#' @export
#' @rdname es_parse
es_parse.elastic_get <- function(input, parsetype='list', verbose=FALSE)
{
  parse_help(input, "elastic_get", parsetype)
  return( tt )
}

#' @method es_parse elastic_mget
#' @export
#' @rdname es_parse
es_parse.elastic_mget <- function(input, parsetype='list', verbose=FALSE)
{
  parse_help(input, "elastic_mget", parsetype)
  return( tt )
}

#' @method es_parse elastic_search
#' @export
#' @rdname es_parse
es_parse.elastic_search <- function(input, parsetype='list', verbose=FALSE)
{
  parse_help(input, "elastic_search", parsetype)
  if(verbose){
    max_score <- tt$hits$max_score
    message(paste("\nmatches -> ", round(tt$hits$total,1), "\nscore -> ",
                  ifelse(is.null(max_score), NA, round(max_score, 3)), sep="")
    )
  }
  return( tt )
}

#' @method es_parse elastic_status
#' @export
#' @rdname es_parse
es_parse.elastic_status <- function(input, parsetype='list', verbose=FALSE)
{
  parse_help(input, "elastic_status", parsetype)
  if(verbose){
    shards <- tt$`_shards`
    message(paste("\nshards -> ", shards$total, "\nsuccessful -> ", shards$successful, sep="")
    )
  }
  return( tt )
}

#' @method es_parse elastic_stats
#' @export
#' @rdname es_parse
es_parse.elastic_stats <- function(input, parsetype='list', verbose=FALSE)
{
  parse_help(input, "elastic_stats", parsetype)
  if(verbose){
    shards <- tt$`_shards`
    message(paste("\nshards -> ", shards$total, "\nsuccessful -> ", shards$successful, sep="")
    )
  }
  return( tt )
}

#' @method es_parse elastic_cluster_health
#' @export
#' @rdname es_parse
es_parse.elastic_cluster_health <- function(input, parsetype='list', verbose=TRUE)
{
  parse_help(input, "elastic_cluster_health", parsetype) 
  if(verbose){
    message(paste("\ncluster_name -> ", tt$cluster_name, "\nstatus -> ", tt$status, sep=""))
  }
  return( tt )
}

#' @method es_parse elastic_cluster_health
#' @export
#' @rdname es_parse
es_parse.elastic_cluster_health <- function(input, parsetype='list', verbose=TRUE)
{
  parse_help(input, "elastic_cluster_health", parsetype) 
  if(verbose){
    message(paste("\ncluster_name -> ", tt$cluster_name, "\nstatus -> ", tt$status, sep=""))
  }
  return( tt )
}

#' @method es_parse elastic_cluster_state
#' @export
#' @rdname es_parse
es_parse.elastic_cluster_state <- function(input, parsetype='list', verbose=TRUE)
{
  parse_help(input, "elastic_cluster_state", parsetype)
  if(verbose){
    message(paste("\ncluster_name -> ", tt$cluster_name, "\nversion -> ", tt$version, sep=""))
  }
  return( tt )
}

#' @method es_parse elastic_cluster_settings
#' @export
#' @rdname es_parse
es_parse.elastic_cluster_settings <- function(input, parsetype='list', verbose=TRUE)
{
  parse_help(input, "elastic_cluster_settings", parsetype)
  return( tt )
}

#' @method es_parse elastic_cluster_stats
#' @export
#' @rdname es_parse
es_parse.elastic_cluster_stats <- function(input, parsetype='list', verbose=TRUE)
{
  parse_help(input, "elastic_cluster_stats", parsetype)
  if(verbose){
    message(paste("\ntimestamp -> ", tt$timestamp, "\ncluster_name -> ", tt$cluster_name, "\nstatus -> ", tt$status, sep=""))
  }
  return( tt )
}

#' @method es_parse elastic_cluster_pending_tasks
#' @export
#' @rdname es_parse
es_parse.elastic_cluster_pending_tasks <- function(input, parsetype='list', verbose=TRUE)
{
  parse_help(input, "elastic_cluster_pending_tasks", parsetype)
  return( tt )
}

#' @method es_parse elastic_nodes_stats
#' @rdname es_parse
es_parse.elastic_nodes_stats <- function(input, parsetype='list', verbose=TRUE)
{
  parse_help(input, "elastic_nodes_stats", parsetype)
  return( tt )
}

#' @method es_parse elastic_nodes_info
#' @rdname es_parse
es_parse.elastic_nodes_info <- function(input, parsetype='list', verbose=TRUE)
{
  parse_help(input, "elastic_nodes_info", parsetype)
  return( tt )
}

parse_help <- function(input, clazz, parsetype){
  assert_that(is(input, clazz))
  tt <<- rjson::fromJSON(input)
  if(parsetype=='list'){ NULL } else {
    message("parsetype='df' not supported yet")
  }
}