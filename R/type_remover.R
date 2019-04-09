#' Utility function to remove 'type' from bulk load files
#' 
#' Types are being removed from Elasticsearch. This little function
#' aims to help remove "_type" fields from bulk newline-delimited JSON
#' files. See Details.
#' 
#' @export
#' @param file (character) a file path, required
#' @return a file path for a temporary file with the types removed
#' @details Looks for any lines that have an "index" key, then drops
#' any "_type" keys in the hash given by the "index" key.
#' 
#' You can of course manually modify these files as an alternative, 
#' in a text editor or with command line tools like sed, etc.
#' @examples \dontrun{
#' z <- system.file("examples/omdb.json", package = "elastic")
#' readLines(z, 6)
#' ff <- type_remover(z)
#' readLines(ff, 6)
#' unlink(ff)
#' }
type_remover <- function(file) {
  assert(file, "character")
  con_in <- file(file)
  txts <- readLines(con_in)
  tmp <- tempfile(fileext = ".json")
  for (i in seq_along(txts)) {
    json <- jsonlite::fromJSON(txts[i], FALSE)
    if ("index" %in% names(json)) json$index$`_type` <- NULL
    cat(jsonlite::toJSON(json, auto_unbox = TRUE),
      sep = "\n", file = tmp, append = TRUE)
  }
  close(con_in)
  return(tmp)
}
