#' @param index Index name, one or more
#' @param type Document type
#' @param q The query string (maps to the query_string query, see Query String 
#' Query for more details). See 
#'https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html
#' for documentation and examples.
#' @param df (character) The default field to use when no field prefix is 
#' defined within the query.
#' @param analyzer (character) The analyzer name to be used when analyzing the
#' query string.
#' @param default_operator (character) The default operator to be used, can be
#' \code{AND} or \code{OR}. Default: \code{OR}
#' @param explain (logical) For each hit, contain an explanation of how 
#' scoring of the hits was computed. Default: \code{FALSE}
#' @param source (logical) Set to \code{FALSE} to disable retrieval of the 
#' \code{_source} field. You can also retrieve part of the document by 
#' using \code{_source_include} & \code{_source_exclude} (see the \code{body} 
#' documentation for more details). You can also include a comma-delimited 
#' string of fields from the source document that you want back. See also 
#' the \strong{fields} parameter
#' @param fields (character) The selective stored fields of the document to 
#' return for each hit. Not specifying any value will cause no fields to return.
#' Note that in Elasticsearch v5 and greater, \strong{fields} parameter has 
#' changed to \strong{stored_fields}, which is not on by default. You can 
#' however, pass fields to \strong{source} parameter
#' @param sort (character) Sorting to perform. Can either be in the form of 
#' fieldName, or \code{fieldName:asc}/\code{fieldName:desc}. The fieldName 
#' can either be an actual field within the document, or the special 
#' \code{_score} name to indicate sorting based on scores. There can be several 
#' sort parameters (order is important).
#' @param track_scores (logical) When sorting, set to \code{TRUE} in order to 
#' still track scores and return them as part of each hit.
#' @param timeout (numeric) A search timeout, bounding the search request to 
#' be executed within the specified time value and bail with the hits 
#' accumulated up to that point when expired. Default: no timeout.
#' @param terminate_after (numeric) The maximum number of documents to collect 
#' for each shard, upon reaching which the query execution will terminate 
#' early. If set, the response will have a boolean field terminated_early to 
#' indicate whether the query execution has actually terminated_early. 
#' Default: no terminate_after
#' @param from (character) The starting from index of the hits to return. 
#' Pass in as a character string to avoid problems with large number 
#' conversion to scientific notation. Default: 0
#' @param size (character) The number of hits to return. Pass in as a 
#' character string to avoid problems with large number conversion to 
#' scientific notation. Default: 10. The default maximum is 10,000 - however, 
#' you can change this default maximum by changing the 
#' \code{index.max_result_window} index level parameter.
#' @param search_type (character) The type of the search operation to perform. 
#' Can be \code{query_then_fetch} (default) or \code{dfs_query_then_fetch}. 
#' Types \code{scan} and \code{count} are deprecated. 
#' See \url{http://bit.ly/19Am9xP} for more details on the different types of 
#' search that can be performed.
#' @param lowercase_expanded_terms (logical) Should terms be automatically 
#' lowercased or not. Default: \code{TRUE}.
#' @param analyze_wildcard (logical) Should wildcard and prefix queries be 
#' analyzed or not. Default: \code{FALSE}.
#' @param version (logical) Print the document version with each document.
#' @param lenient If \code{TRUE} will cause format based failures (like 
#' providing text to a numeric field) to be ignored. Default: \code{FALSE}
#' @param raw (logical) If \code{FALSE} (default), data is parsed to list. 
#' If \code{TRUE}, then raw JSON returned
#' @param asdf (logical) If \code{TRUE}, use \code{\link[jsonlite]{fromJSON}} 
#' to parse JSON directly to a data.frame. If \code{FALSE} (Default), list 
#' output is given.
#' @param stream_opts (list) A list of options passed to 
#' \code{\link[jsonlite]{stream_out}} - Except that you can't pass \code{x} as 
#' that's the data that's streamed out, and pass a file path instead of a 
#' connection to \code{con}. \code{pagesize} param doesn't do much as 
#' that's more or less controlled by paging with ES.
#' @param ... Curl args passed on to \code{\link[httr]{POST}}
