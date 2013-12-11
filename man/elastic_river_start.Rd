\name{elastic_river_start}
\alias{elastic_river_start}
\title{Start indexing a CouchDB database using Elasticsearch.}
\usage{
elastic_river_start(dbname, endpoint = "http://localhost", port = 9200)
}
\arguments{
  \item{dbname}{Database name. (charcter)}

  \item{endpoint}{the endpoint, defaults to localhost
  (http://127.0.0.1)}

  \item{port}{port to connect to, defaults to 9200}
}
\description{
Start indexing a CouchDB database using Elasticsearch.
}
\details{
The function returns TRUE. Though note that this can result
even if the database does not exist in CouchDB.
}
\examples{
\dontrun{
library(sofa)
sofa_createdb(dbname='alm_couchdb')
elastic_river_start(dbname="alm_couchdb")
}
}
\references{
See docs for the Elasticsearch River plugin \url{#} that
lets you easily index CouchDB databases.
}

