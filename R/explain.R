#' Explain a search query.
#'
#' @export
#' @param index Only one index
#' @param type Only one document type
#' @param id Document id, only one
#' @param source2 (logical) Set to TRUE to retrieve the _source of the document explained. You can
#' also retrieve part of the document by using source_include & source_exclude (see Get API
#' for more details). This matches the \code{_source} term, but we want to avoid the leading
#' underscore.
#' @param source_exclude A vector of fields to exclude from the returned source2 field
#' @param source_include A vector of fields to extract and return from the source2 field
#' @param fields Allows to control which stored fields to return as part of the document explained.
#' @param routing Controls the routing in the case the routing was used during indexing.
#' @param parent Same effect as setting the routing parameter.
#' @param preference Controls on which shard the explain is executed.
#' @param source Allows the data of the request to be put in the query string of the url.
#' @param q The query string (maps to the query_string query).
#' @param df The default field to use when no field prefix is defined within the query. Defaults
#' to _all field.
#' @param analyzer The analyzer name to be used when analyzing the query string. Defaults to the
#' analyzer of the _all field.
#' @param analyze_wildcard (logical) Should wildcard and prefix queries be analyzed or not.
#' Default: FALSE
#' @param lowercase_expanded_terms Should terms be automatically lowercased or not. Default: TRUE
#' @param lenient If set to true will cause format based failures (like providing text to a
#' numeric field) to be ignored. Default: FALSE
#' @param default_operator The default operator to be used, can be AND or OR. Defaults to OR.
#' @param body The query definition using the Query DSL. This is passed in the body of the
#' request.
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @references
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html}
#' @examples \dontrun{
#' explain(index = "plos", type = "article", id = 14, q = "abstract:used")
#'
#' body <- '{
#'  "query": {
#'    "term": { "abstract": "used" }
#'  }
#' }'
#' explain(index = "plos", type = "article", id = 14, body=body)
#' }

explain <- function(index=NULL, type=NULL, id=NULL, source2=NULL, fields=NULL, routing=NULL,
  parent=NULL, preference=NULL, source=NULL, q=NULL, df=NULL, analyzer=NULL, analyze_wildcard=FALSE,
  lowercase_expanded_terms=TRUE, lenient=FALSE, default_operator=NULL, source_exclude=NULL,
  source_include=NULL, body=NULL, raw=FALSE, ...) {
  
  checkconn()
  args <- ec(list(`_source`=source2, fields=fields, routing=routing, parent=parent,
          preference=preference, source=source, q=q, df=df, analyzer=analyzer,
          analyze_wildcard=as_log(analyze_wildcard), lowercase_expanded_terms=as_log(lowercase_expanded_terms),
          lenient=as_log(lenient), default_operator=default_operator, `_source_exclude`=source_exclude,
          `_source_include`=source_include))
  explain_POST(esc(index), esc(type), id, args, body, raw, ...)
}

explain_POST <- function(index, type, id, args, body, raw, ...) {
  url <- make_url(es_get_auth())
  url <- if(is.null(id)) file.path(url, index, type, "_explain") else file.path(url, index, type, id, "_explain")
  tt <- if(is.null(body)) POST(url, query=args, make_up(), ...) else POST(url, query=args, body=body, make_up(), ...)
  geterror(tt)
  # stop_for_status(tt)
  if (raw) content(tt, "text") else jsonlite::fromJSON(content(tt, "text"), FALSE)
}
