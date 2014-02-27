\name{es_mget}
\alias{es_mget}
\title{Get multiple documents via the multiple get API.}
\usage{
es_mget(conn, index = NULL, type = NULL, id = NULL, type_id = NULL,
  index_type_id = NULL, source = NULL, fields = NULL, raw = FALSE,
  callopts = list(), verbose = TRUE, ...)
}
\arguments{
  \item{conn}{Connection object describing base url, port,
  and any authentication details.}

  \item{index}{Index}

  \item{type}{Document type}

  \item{raw}{If TRUE (default), data is parsed to list. If
  FALSE, then raw JSON.}

  \item{callopts}{Curl args passed on to httr::POST.}

  \item{verbose}{If TRUE (default) the url call used
  printed to console.}

  \item{...}{Further args passed on to elastic search HTTP
  API as parameters.}

  \item{id}{Document id}

  \item{source}{XXX}

  \item{fields}{Fields to return from the response object.}

  \item{type_id}{List of vectors of length 2, each with an
  element for type and id.}

  \item{index_type_id}{List of vectors of length 3, each
  with an element for index, type, and id.}
}
\description{
Get multiple documents via the multiple get API.
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

# Same index and type
es_mget(init, index="twitter", type="tweet", id=1:2)
tmp <- es_mget(init, index="twitter", type="tweet", id=1:2, raw=TRUE)
es_parse(tmp)
es_mget(init, index="twitter", type="tweet", id=1:2, fields='user')
es_mget(init, index="twitter", type="tweet", id=1:2, source=TRUE)

library(httr)
es_mget(init, index="twitter", type="tweet", id=1:2, callopts=verbose())

# Same index, but different types
es_mget(init, index="twitter", type_id=list(c("tweet",1), c("mention",2)))
es_mget(init, index="twitter", type_id=list(c("tweet",1), c("mention",2)), fields='user')
es_mget(init, index="twitter", type_id=list(c("tweet",1), c("mention",2)), fields=c('user','message'))

# Different indeces and different types
# pass in separately
es_mget(init, index_type_id=list(c("twitter","mention",1), c("appdotnet","share",1)))
}
}

