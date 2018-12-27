ec <- function(l) Filter(Negate(is.null), l)

cont_utf8 <- function(x) content(x, as = "text", encoding = "UTF-8")

as_log <- function(x){
  if (is.null(x)) {
    x
  } else {
    if (x) 'true' else 'false'
  }
}

`%|||%` <- function(x, y) if (x == "false") y else x

cl <- function(x) if (is.null(x)) NULL else paste0(x, collapse = ",")

cw <- function(x) if (is.null(x)) x else paste(x, collapse = ",")

esc <- function(x) {
  if (is.null(x)) {
    NULL
  } else {
    curl::curl_escape(x)
  }
}

pluck <- function(x, name, type) {
  if (missing(type)) {
    lapply(x, "[[", name)
  } else {
    vapply(x, "[[", name, FUN.VALUE = type)
  }
}

make_up <- function() {
  up <- es_get_user_pwd()
  if (nchar(up$user) != 0 && nchar(up$pwd) != 0) {
    authenticate(up$user, up$pwd)
  } else {
    list()
  }
}

# Make sure variable is a numeric or integer --------------
cn <- function(x) {
  name <- substitute(x)
  if (!is.null(x)) {
    tryx <- tryCatch(as.numeric(as.character(x)), warning = function(e) e)
    if ("warning" %in% class(tryx)) {
      stop(name, " should be a numeric or integer class value", call. = FALSE)
    }
    if (!inherits(tryx, "numeric") | is.na(tryx))
      stop(name, " should be a numeric or integer class value", call. = FALSE)
    return( format(x, digits = 22, scientific = FALSE) )
  } else {
    NULL
  }
}

strmatch <- function(x, y) regmatches(x, regexpr(y, x))

strloc2match <- function(x, first, y) substring(x, first, regexpr(y, x) - 1)

prune_trailing_slash <- function(x) {
  gsub("\\/$", "", x)
}

construct_url <- function(url, path, index, type = NULL, id = NULL) {
  index <- esc(index)
  type <- esc(type)
  if (is.null(index) && is.null(type)) {
    paste(url, path, sep = "/")
  } else {
    if (is.null(type) && !is.null(index)) {
      paste(url, index, path, sep = "/")
    } else if (!is.null(type) && !is.null(index) && is.null(id)) {
      paste(url, index, type, path, sep = "/")
    } else if (!is.null(type) && !is.null(index) && !is.null(id)) {
      paste(url, index, type, id, path, sep = "/")
    } else if (!is.null(type) && is.null(index) && !is.null(id)) {
      stop("If a document ID is given, an index type must be given", 
           call. = FALSE)
    }
  }
}

extractr <- function(x, y) regmatches(x, gregexpr(y, x))

assert <- function(x, y) {
  if (!is.null(x)) {
    if (!class(x) %in% y) {
      stop(deparse(substitute(x)), " must be of class ",
           paste0(y, collapse = ", "), call. = FALSE)
    }
  }
}

write_utf8 = function(text, con, ...) {
  # prevent re-encoding the text in the file() connection in writeLines()
  # https://kevinushey.github.io/blog/2018/02/21/string-encoding-and-r/
  opts = options(encoding = 'native.enc'); on.exit(options(opts), add = TRUE)
  writeLines(enc2utf8(text), con, ..., useBytes = TRUE)
}

json_type <- function() list(`Content-Type` = "application/json")

is_conn <- function(x) {
  if (!inherits(x, "Elasticsearch")) {
    stop("'conn' must be an elastic connection object; see ?connect", 
      call. = FALSE)
  }
}
