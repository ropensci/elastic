ec <- function (l) Filter(Negate(is.null), l)

as_log <- function(x){
  stopifnot(is.logical(x))
  if(x) 'true' else 'false'
}

cl <- function(x) paste0(x, collapse = ",")
