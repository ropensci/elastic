#' The elastic DSL
#' 
#' @import lazyeval
#' @name elasticdsl
#' 
#' @param index asdfds
#' @param type asdfds
#' @param what asdfds
#' @param .obj asdfds
#' @param x adfadf
#' @param ... adfadsf
#' @details 
#' The DSL for \code{elastic} makes it easy to do queries against an Elasticsearch 
#' instance, either local or remote. 
#' 
#' The workflow with the DSL:
#' \enumerate{
#'  \item Start with the index to use, e.g., \code{index("shakespeare")}
#'  \item Define queries, e.g., \code{range(speech_number == 5, line_id > 3)}
#'  \item Execute search, e.g., \code{Search()}
#' }
#' 
#' Alternatively, if nothing follows a query definition, \code{\link{Search}} is called
#' to execute the search with the query as given. In a sense, this is essentially like 
#' what \code{\link{dplyr}} does.
#' @examples \dontrun{
#' # Get mapping for verifying fields requested in DSL
#' index("shakespeare")
#' index("plos")
#' index("gbif")
#' 
#' # Define bool query for the DSL
#' index("shakespeare") %>% 
#'    bool(must = list(term=list(user="kimchy")))
#' bool(must_not = list(term=list(user="kimchy")))
#' bool(should = list(list(term=list(tag="sometag")), list(term=list(tag="someothertag"))))
#' 
#' bool(must = list(term=list(user="kimchy")), 
#'      must_not = list(term=list(user="kimchy")))
#'      
#' # Define range query for the DSL
#' range( speech_number == 5, line_id > 3 )
#' range( speech_number <= c(1,5) )
#' range( speech_number >= c(1,5) )
#' }
NULL

#' @export
#' @rdname elasticdsl
index <- function(index, type=NULL, what="mappings", ...){
  structure(get_map(index, type, ...), class="index", index=index, type=type)
}

#' @export
#' @rdname elasticdsl
print.index <- function(x, ...){
  cat("<index>", attr(x, "index"), "\n")
  cat("  type:", attr(x, "type"), "\n")
  nmz <- names(x)
  cat("  mappings:", "\n")
  for(i in seq_along(nmz)){
    cat(sprintf("    %s:", nmz[i]), "\n")
    for(j in seq_along(x[[i]]$properties)){
      tmp <- x[[i]]$properties[j]
      cat(sprintf("      %s: %s", names(tmp), tmp[[1]]$type), "\n")
    }
  }
}

#' @export
#' @rdname elasticdsl
range <- function(.obj=list(), ..., boost=1, cache=FALSE) {
  combine(.obj, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname elasticdsl
bool <- function(.obj=list(), ...){
  combine(.obj, .dots = lazyeval::lazy_dots(...))
  # structure(unclass(tmp), class=c("equ","lazy_dots"))
}

# combine query statements
combine <- function(.obj, ..., .dots){
  c(.obj, lazyeval::all_dots(.dots, ...))
}

# shake <- get_map("shakespeare")
# shake$line
# # field names
# names(shake$line$properties)
# # field types
# pluck(shake$line$properties, "type", "")
# shake$scene
# shake$act
get_map <- function(index, type=NULL, ...){
  tmp <- mapping_get(index, type, ...)
  tmp[[index]]$mappings
}

# #' @export
# print.equ <- function(x, pretty = TRUE, auto_unbox = TRUE, ...){
#   print(jsonlite::toJSON(unclass(x), pretty=pretty, auto_unbox = auto_unbox))
# }

######
# parse_input <- function(...){
#   x <- as.character(dots(...))
#   neg <- gsub('-', '', x[grepl("-", x)])
#   pos <- x[!grepl("-", x, )]
#   list(neg=neg, pos=pos)
# }
# 
# dots <- function(...){
#   eval(substitute(alist(...)))
# }

#####
# select <- function (.data, ...) {
#   select_(.data, .dots = lazyeval::lazy_dots(...))
# }
# 
# select_.data.frame <- function (.data, ..., .dots) {
#   lazyeval::all_dots(.dots, ...)
# #   vars <- select_vars_(names(.data), dots)
# #   select_impl(.data, vars)
# }
# 
# lazy_dots <- function (..., .follow_symbols = FALSE) {
#   if (nargs() == 0) 
#     return(structure(list(), class = "lazy_dots"))
#   .Call(make_lazy_dots, environment(), .follow_symbols)
# }
