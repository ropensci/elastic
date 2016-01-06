#' Search field statistics
#'
#' @export
#' @param fields A list of fields to compute stats for. Required.
#' @param index Index name, one or more
#' @param level Defines if field stats should be returned on a per index level or
#' on a cluster wide level. Valid values are 'indices' and 'cluster' (default).
#' @param body Query, either a list or json.
#' @param raw (logical) Get raw JSON back or not.
#' @param asdf (logical) If \code{TRUE}, use \code{\link[jsonlite]{fromJSON}} to parse JSON
#' directly to a data.frame. If \code{FALSE} (Default), list output is given.
#' @param ... Curl args passed on to \code{\link[httr]{POST}}
#'
#' @details The field stats api allows you to get statistical properties of a field
#' without executing a search, but looking up measurements that are natively available
#' in the Lucene index. This can be useful to explore a dataset which you don't know
#' much about. For example, this allows creating a histogram aggregation with meaningful
#' intervals based on the min/max range of values.
#'
#' The field stats api by defaults executes on all indices, but can execute on specific
#' indices too.
#' @seealso \code{\link{Search_uri}} \code{\link{Search}} \code{\link{msearch}}
#' @examples \dontrun{
#' connect()
#' ff <- c("scientificName", "continent", "decimalLatitude", "play_name", "speech_number")
#' field_stats("play_name")
#' field_stats("play_name", level = "cluster")
#' field_stats(ff, level = "indices")
#' field_stats(ff)
#' field_stats(ff, index = c("gbif", "shakespeare"))
#'
#' # can also pass a body, just as with Search()
#' # field_stats(body = list(fields = "rating")) # doesn't work
#' field_stats(body = '{ "fields": ["scientificName"] }', index = "gbif")
#'
#' body <- '{
#'    "fields" : ["scientificName", "decimalLatitude"]
#' }'
#' field_stats(body = body, level = "indices", index = "gbif")
#' }
field_stats <- function(fields = NULL, index = NULL, level = "cluster", body = list(),
                        raw = FALSE, asdf = FALSE, ...) {

  stop_es_version(160, "field_stats")
  if (!is.null(fields)) fields <- paste(fields, collapse = ",")
  args <- ec(list(fields = fields, level = level))
  search_POST("_field_stats", cl(esc(index)), args = args, body = body, raw = raw, asdf = asdf, ...)
}
