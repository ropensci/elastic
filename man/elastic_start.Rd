\name{elastic_start}
\alias{elastic_start}
\title{Start indexing a CouchDB database using Elasticsearch.}
\usage{
  elastic_start(dbname, endpoint = "http://localhost",
    port = 9200)
}
\arguments{
  \item{dbname}{Database name. (charcter)}

  \item{endpoint}{the endpoint, defaults to localhost
  (http://127.0.0.1)}

  \item{port}{port to connect to, defaults to 5984}
}
\description{
  Start indexing a CouchDB database using Elasticsearch.
}
\details{
  The function returns TRUE. Though note that this can
  result even if the database does not exist in CouchDB.
}
\examples{
\dontrun{
sofa_createdb(dbname='shitty2')
elastic_start(dbname="shitty2")
}
}

