\name{es_cdbriver_start}
\alias{es_cdbriver_start}
\title{Start indexing a CouchDB database using Elasticsearch.}
\usage{
es_cdbriver_start(dbname, endpoint = "http://localhost", port = 9200)
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
library(devtools)
install_github("sckott/sofa")
library(sofa)
sofa_createdb(dbname='mydb')
es_cdbriver_start(dbname='mydb')
}
}
\references{
See docs for the Elasticsearch River plugin \url{#} that
lets you easily index CouchDB databases.
}

