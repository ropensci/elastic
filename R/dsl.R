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
#' index("shakespeare", "scene")
#' index("shakespeare", "act")
#' index("plos")
#' index("gbif")
#' 
#' # Define bool query
#' bool(must_not = list(term=list(speaker="KING HENRY IV")))
#' index("shakespeare") %>% 
#'    bool(must = list(term=list(speaker="KING HENRY IV")))
#' index("shakespeare") %>% 
#'    bool(must_not = list(term=list(speaker="KING HENRY IV")))
#' index("shakespeare") %>% 
#'    bool(should = list(list(term=list(speech_number=1))))
#' 
#' bool(must = list(term=list(user="kimchy")), 
#'      must_not = list(term=list(user="kimchy")))
#'      
#' # Define range query
#' index("shakespeare") %>% range( speech_number <= 5 )
#' index("shakespeare") %>% range( speech_number <= c(1,5) )
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
range <- function(.obj=list(), ..., boost=1, time_zone=NULL, execution=NULL, cache=FALSE) {
  range_(.obj, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname elasticdsl
range_ <- function(.obj=list(), ..., .dots) {
  dots <- lazyeval::all_dots(.dots, ...)
  query <- as.json(structure(dots, class=c("range","lazy_dots")))
  execute(.obj, query)
}

#' @export
#' @rdname elasticdsl
bool <- function(.obj=list(), ...){
  bool_(.obj, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname elasticdsl
bool_ <- function(.obj=list(), ..., .dots){
  dots <- lazyeval::all_dots(.dots, ...)
  query <- as.json(structure(dots, class=c("bool","lazy_dots")))
  execute(.obj, query)
}

as.json <- function(x, ...) UseMethod("as.json")

as.json.range <- function(x, ...){
  x <- list(query = list(range = parse_range(get_eq(x[[1]]))))
  jsonlite::toJSON(x, ..., auto_unbox = TRUE)
}

as.json.bool <- function(x, ...){
  tmp <- setNames(list(lazy_eval(x[[1]]$expr)), names(x))
  x <- list(query = list(bool = tmp))
  jsonlite::toJSON(x, ..., auto_unbox = TRUE)
}

get_eq <- function(y) {
  dat <- getParseData(parse(text = deparse(y$expr)))
  tmp <- list(var = dat[ dat$token == "SYMBOL", "text"],
              eq = dat$token[ dat$token %in% c("LT","GT","GE","LE","EQ_ASSIGN","EQ","NE") ],
              num = dat[ dat$token == "NUM_CONST", "text"]
  )
  tmp$eq <- switch(tolower(tmp$eq), lt="lt", gt="gt", ge="gte", le="lte", eq_assign=NA, eq=NA)
  tmp
}

parse_range <- function(x){
  setNames(list(as.list(setNames(x$num, x$eq))), x$var)
}

# combine query statements
combine <- function(.obj, ..., .dots){
  list(.obj, lazyeval::all_dots(.dots, ...))
}

# execute on Search
execute <- function(.obj, query){
  # query <- lazyeval::lazy_eval(query)
  # query <- as.json(query)
  Search_(index=attr(.obj, "index"), body=query)
}

# explain <- function(.obj=list(), ...){
#   lazyeval::lazy_dots(...)
#   # explain_(.obj, .dots = lazyeval::lazy_dots(...))
# }
# 
# explain_ <- function(.obj=list(), ..., .dots){
#   dots <- lazyeval::all_dots(.dots, ...)
#   dots
#   # structure(dots, class=c("explain","lazy_dots"))
# }

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
