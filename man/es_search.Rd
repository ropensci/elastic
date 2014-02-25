\name{es_search}
\alias{es_search}
\title{Full text search of any CouchDB databases using Elasticsearch.}
\usage{
es_search(conn, index = NULL, type = NULL, parse = TRUE, verbose = TRUE,
  callopts = list(), ...)
}
\arguments{
  \item{url}{the url, defaults to localhost
  (http://127.0.0.1)}

  \item{port}{port to connect to, defaults to 5984}

  \item{dbname}{Database name. (charcter)}

  \item{parse}{If TRUE (default), data is parsed to list.
  If FALSE, then raw JSON.}

  \item{verbose}{Verbosity (default) or not. Ignored if
  parse=FALSE}

  \item{...}{Further args passed on to elastic search HTTP
  API.}
}
\description{
Full text search of any CouchDB databases using
Elasticsearch.
}
\details{
There are a lot of terms you can use for Elasticsearch. See
here
\url{http://www.elasticsearch.org/guide/reference/query-dsl/}
for the documentation.
}
\examples{
\dontrun{
init <- es_connect()
es_search(init, index="twitter")
es_search(init, index="twitter", type="tweet")
es_search(init, index="twitter", type="mention")
es_search(init, index="twitter", type="tweet", q="what")
es_search(init, index="twitter", type="tweet", sort="message")

# Get raw data
es_search(init, index="twitter", type="tweet", parse=FALSE)
}
}

