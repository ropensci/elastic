#' The elastic DSL
#' 
#' @import lazyeval
#' @importFrom jsonlite unbox
#' @name elasticdsl
#' 
#' @param index Index name
#' @param type Type name, Default: NULL, so all types
#' @param what In \code{\link{index}}, whether to get mappings, aliases, or settings.
#' @param .obj An index object. If nothing passed defaults to all indices, equivalent to 
#' doing e.g., \code{localhost:9200/_search}
#' @param x Input to various functions
#' @param ... Further args passed on
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
#' # Define index
#' index("shakespeare")
#' index("shakespeare", "scene")
#' index("shakespeare", "act")
#' index("plos")
#' index("gbif")
#' 
#' # DSL queries default to search across all indices
#' bool(must_not = list(term=list(speaker="KING HENRY IV")))
#' 
#' # bool query
#' bool(must_not = list(term=list(speaker="KING HENRY IV")))
#' index("shakespeare") %>% 
#'    bool(must_not = list(term=list(speaker="KING HENRY IV")))
#' index("shakespeare") %>% 
#'    bool(should = list(list(term=list(speech_number=1))))
#'
#' # range query
#' index("shakespeare") %>% range( speech_number <= 5 )
#' index("shakespeare") %>% range( speech_number <= c(1,5) ) # doens't work
#' index("shakespeare") %>% range( speech_number >= c(1,5) ) # doens't work
#' 
#' # geographic query
#' ## point
#' index("geoshape") %>% 
#'    geoshape(field = "location", type = "envelope", coordinates = list(c(-30, 50), c(30, 0)))
#' # circle and radius
#' index("geoshape") %>% 
#'    geoshape(field = "location", type = "circle", radius = "2000km", 
#'             coordinates = c(-10, 45)) %>% 
#'    n()
#' index("geoshape") %>% 
#'    geoshape(field = "location", type = "circle", radius = "5000km", 
#'             coordinates = c(-10, 45)) %>% 
#'    n()
#' # polygon
#' coords <- list(c(80.0, -20.0), c(-80.0, -20.0), c(-80.0, 60.0), c(40.0, 60.0), c(80.0, -20.0))
#' index("geoshape") %>% 
#'    geoshape(field = "location", type = "polygon", coordinates = coords)
#' 
#' # limit query
#' filter()
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

#' @export
#' @rdname elasticdsl
geoshape <- function(.obj=list(), ..., field=NULL){
  geoshape_(.obj, .dots = lazyeval::lazy_dots(...), field=field)
}

#' @export
#' @rdname elasticdsl
geoshape_ <- function(.obj=list(), ..., .dots, field=NULL){
  dots <- lazyeval::all_dots(.dots, ...)
  query <- as.json(structure(dots, class=c("geoshape","lazy_dots")), field=field)
  execute(.obj, query)
}

#' @export
#' @rdname elasticdsl
n <- function(x) x$hits$total

#' @export
#' @rdname elasticdsl
filter <- function(){
  list(filtered = TRUE)
}

#' @export
#' @rdname elasticdsl
boosting <- function(.obj=list(), ..., negative_boost=NULL){
  boosting_(.obj, .dots = lazyeval::lazy_dots(...), negative_boost=negative_boost) 
}

#' @export
#' @rdname elasticdsl
boosting_ <- function(.obj=list(), ..., .dots, negative_boost=NULL){
  dots <- lazyeval::all_dots(.dots, ...)
  query <- as.json(structure(dots, class=c("boosting","lazy_dots")), negative_boost=negative_boost)
  execute(.obj, query)
}

#' @export
#' @rdname elasticdsl
common <- function(.obj=list(), field, query=NULL, cutoff_frequency=NULL, low_freq_operator=NULL, 
                   minimum_should_match=NULL){
  common_(.obj, field=field, query=query,
          cutoff_frequency=cutoff_frequency,
          low_freq_operator=low_freq_operator, 
          minimum_should_match=minimum_should_match)
}

#' @export
#' @rdname elasticdsl
common_ <- function(.obj=list(), field, query=NULL, cutoff_frequency=NULL, low_freq_operator=NULL, 
                    minimum_should_match=NULL){
  args <- ec(list(field=field, query=query,
          cutoff_frequency=cutoff_frequency,
          low_freq_operator=low_freq_operator, 
          minimum_should_match=minimum_should_match))
  dots <- lazyeval::as.lazy_dots(args)
  query <- as.json(
    structure(dots, class=c("common","lazy_dots"))
  )
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

as.json.geoshape <- function(x, field, ...){
  out <- list()
  for(i in seq_along(x)){
    dat <- if(is.character(x[[i]]$expr)){
      unbox(x[[i]]$expr)
    } else {
      list(eval(x[[i]]$expr))
    }
    out[[names(x[i])]] <- dat
  }
  tmp <- setNames(list(list(shape = out)), field)
  alldat <- list(query = list(geo_shape = tmp))
  json <- jsonlite::toJSON(alldat, ..., auto_unbox = TRUE)
  gsub_geoshape(out$type[[1]], json)
}

as.json.common <- function(x, field, ...){
  tmp <- setNames(list(list(query = as.character(x$query$expr), 
                            cutoff_frequency = as.numeric(x$cutoff_frequency$expr))), 
                  as.character(x$field$expr))
  alldat <- list(query = list(common = tmp))
  jsonlite::toJSON(alldat, ..., auto_unbox = TRUE)
}

gsub_geoshape <- function(type, x){
  switch(type, 
         envelope = gsub('\\]\\]\\]', "\\]\\]", gsub('\\[\\[\\[', "\\[\\[", x)),
         circle = gsub('\\]\\]', "\\]", gsub('\\[\\[', "\\[", x)),
         polygon = x
  )
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
  Search_(.obj, body=query)
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
