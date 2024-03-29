% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/docs_bulk_index.R
\name{docs_bulk_index}
\alias{docs_bulk_index}
\title{Use the bulk API to index documents}
\usage{
docs_bulk_index(
  conn,
  x,
  index = NULL,
  type = NULL,
  chunk_size = 1000,
  doc_ids = NULL,
  es_ids = TRUE,
  raw = FALSE,
  quiet = FALSE,
  query = list(),
  digits = NA,
  sf = NULL,
  ...
)
}
\arguments{
\item{conn}{an Elasticsearch connection object, see \code{\link[=connect]{connect()}}}

\item{x}{A list, data.frame, or character path to a file. required.}

\item{index}{(character) The index name to use. Required for data.frame
input, but optional for file inputs.}

\item{type}{(character) The type. default: \code{NULL}. Note that \code{type} is
deprecated in Elasticsearch v7 and greater, and removed in Elasticsearch v8}

\item{chunk_size}{(integer) Size of each chunk. If your data.frame is smaller
thank \code{chunk_size}, this parameter is essentially ignored. We write in
chunks because at some point, depending on size of each document, and
Elasticsearch setup, writing a very large number of documents in one go
becomes slow, so chunking can help. This parameter is ignored if you
pass a file name. Default: 1000}

\item{doc_ids}{An optional vector (character or numeric/integer) of document
ids to use. This vector has to equal the size of the documents you are
passing in, and will error if not. If you pass a factor we convert to
character. Default: not passed}

\item{es_ids}{(boolean) Let Elasticsearch assign document IDs as UUIDs.
These are sequential, so there is order to the IDs they assign.
If \code{TRUE}, \code{doc_ids} is ignored. Default: \code{TRUE}}

\item{raw}{(logical) Get raw JSON back or not. If \code{TRUE}
you get JSON; if \code{FALSE} you get a list. Default: \code{FALSE}}

\item{quiet}{(logical) Suppress progress bar. Default: \code{FALSE}}

\item{query}{(list) a named list of query parameters. optional.
options include: pipeline, refresh, routing, _source, _source_excludes,
_source_includes, timeout, wait_for_active_shards. See the docs bulk
ES page for details}

\item{digits}{digits used by the parameter of the same name by
\code{\link[jsonlite:fromJSON]{jsonlite::toJSON()}} to convert data to JSON before being submitted to
your ES instance. default: \code{NA}}

\item{sf}{used by \code{\link[jsonlite:fromJSON]{jsonlite::toJSON()}} to convert sf objects.
Set to "features" for conversion to GeoJSON. default: "dataframe"}

\item{...}{Pass on curl options to \link[crul:HttpClient]{crul::HttpClient}}
}
\description{
Use the bulk API to index documents
}
\details{
For doing index with a file already prepared for the bulk API,
see \code{\link[=docs_bulk]{docs_bulk()}}

Only data.frame's are supported for now.
}
\examples{
\dontrun{
x <- connect()
if (index_exists(x, "foobar")) index_delete(x, "foobar")

df <- data.frame(name = letters[1:3], size = 1:3, id = 100:102)
docs_bulk_index(x, df, 'foobar')
docs_bulk_index(x, df, 'foobar', es_ids = FALSE)
Search(x, "foobar", asdf = TRUE)$hits$hits

# more examples
docs_bulk_index(x, mtcars, index = "hello")
## field names cannot contain dots
names(iris) <- gsub("\\\\.", "_", names(iris))
docs_bulk_index(x, iris, "iris")
## type can be missing, but index can not
docs_bulk_index(x, iris, "flowers")
## big data.frame, 53K rows, load ggplot2 package first
# res <- docs_bulk_index(x, diamonds, "diam")
# Search(x, "diam")$hits$total$value
}
}
\references{
\url{https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html}
}
\seealso{
Other bulk-functions: 
\code{\link{docs_bulk_create}()},
\code{\link{docs_bulk_delete}()},
\code{\link{docs_bulk_prep}()},
\code{\link{docs_bulk_update}()},
\code{\link{docs_bulk}()}
}
\concept{bulk-functions}
