\name{es_get}
\alias{es_get}
\title{Get documents via the get API.}
\usage{
es_get(conn, index = NULL, type = NULL, id = NULL, parse = TRUE,
  verbose = TRUE, callopts = list(), ...)
}
\arguments{
  \item{conn}{Connection object describing base url, port,
  and any authentication details.}

  \item{url}{the url, defaults to localhost
  (http://127.0.0.1)}

  \item{port}{port to connect to, defaults to 5984}

  \item{index}{Index}

  \item{type}{Document type}

  \item{id}{Document id}

  \item{verbose}{Verbosity (default) or not. Ignored if
  parse=FALSE}

  \item{...}{Further args passed on to elastic search HTTP
  API.}
}
\description{
Get documents via the get API.
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
es_get(init, index='twitter', type='tweet', id=1)
}
}

