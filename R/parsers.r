#' Parse raw data from es_get, es_mget, or es_search.
#' 
#' See details.
#' 
#' @import assertthat
#' @importFrom rjson fromJSON
#' @param input Output from solr_facet
#' @param parsetype One of 'list' or 'df' (data.frame)
#' @param verbose Print messages or not (default: FALSE).
#' @details This is the parser used internally in es_get, es_mget, and es_search, 
#' but if you output raw data from solr_facet using raw=TRUE, then you can use this 
#' function to parse that data (a sr_facet S3 object) after the fact to a list of data.frame's for easier 
#' consumption. The data format type is detected from the attribute "wt" on the 
#' sr_facet object.
#' @export
es_parse <- function(input, parsetype, verbose){
  UseMethod("es_parse")
}

#' @method es_parse elastic_get
#' @export
#' @rdname es_parse
es_parse.elastic_get <- function(input, parsetype=NULL, verbose=FALSE)
{
  assert_that(is(input, "elastic_get"))
  tt <- rjson::fromJSON(input)
  return( tt )
}

#' @method es_parse elastic_mget
#' @export
#' @rdname es_parse
es_parse.elastic_mget <- function(input, parsetype=NULL, verbose=FALSE)
{
  assert_that(is(input, "elastic_mget"))
  tt <- rjson::fromJSON(input)
  return( tt )
}

#' @method es_parse elastic_search
#' @export
#' @rdname es_parse
es_parse.elastic_search <- function(input, parsetype=NULL, verbose=FALSE)
{
  assert_that(is(input, "elastic_search"))
  tt <- rjson::fromJSON(input)
  
  if(verbose){
    max_score <- tt$hits$max_score
    message(paste("\nmatches -> ", round(tt$hits$total,1), "\nscore -> ", 
                  ifelse(is.null(max_score), NA, round(max_score, 3)), sep="")
    )
  }
  return( tt )
}