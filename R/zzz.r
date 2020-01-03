ec <- function(l) Filter(Negate(is.null), l)

as_log <- function(x){
  if (is.null(x)) {
    x
  } else {
    if (x) 'true' else 'false'
  }
}

ck <- function(x){
  if (is.null(x) || is.numeric(x)) {
    x
  } else if (is.logical(x)) {
    as_log(x)
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
    file.path(url, path)
  } else {
    if (is.null(type) && !is.null(index) && is.null(id)) {
      file.path(url, index, path)
    } else if (is.null(type) && !is.null(index) && !is.null(id)) {
      file.path(url, index, path, id)
    } else if (!is.null(type) && !is.null(index) && is.null(id)) {
      file.path(url, index, type, path)
    } else if (!is.null(type) && !is.null(index) && !is.null(id)) {
      file.path(url, index, type, id, path)
    } else if (!is.null(type) && is.null(index) && !is.null(id)) {
      stop("If a document ID is given, an index type must be given", 
           call. = FALSE)
    }
  }
}

extractr <- function(x, y) regmatches(x, gregexpr(y, x))

assert <- function(x, y) {
  if (!is.null(x)) {
    if (!inherits(x, y)) {
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

ph <- function(x) {
  if (is.null(x)) {
    'NULL'
  } else {
    str <- paste0(names(x$headers), collapse = ", ")
    if (nchar(str) > 30) paste0(substring(str, 1, 30), " ...") else str
  }
}

es_get_user_pwd <- function() {
  user <- Sys.getenv("ES_USER")
  pwd <- Sys.getenv("ES_PWD")
  list(user = user, pwd = pwd)
}

type_deprecated <- function(conn, type = NULL) { 
  z <- "Types in search queries are deprecated, filter on a field instead"
  if (conn$es_ver() >= 700) {
    if (!is.null(type)) warning(z)
  }  
}

catch_warnings <- function(z) {
  assert(z, "HttpResponse")
  hds <- z$response_headers
  if ("warning" %in% names(hds)) {
    hds_warn <- hds[names(hds) %in% "warning"]
    mssg <- unname(vapply(hds_warn, parse_es_warning, ""))
    for (i in seq_along(mssg)) warning(mssg[i], call. = FALSE)
  }
}

parse_es_warning <- function(w) {
  strsplit(w, "\"")[[1]][2]
}
