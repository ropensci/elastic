\name{elastic_river_auth}
\alias{elastic_river_auth}
\title{Start indexing a CouchDB database using Elasticsearch.}
\usage{
elastic_river_auth(user = NULL, pwd = NULL)
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
elastic_river_auth(user="foo", pwd="bar")
}
}
\references{
See docs for the Elasticsearch River plugin \url{#} that
lets you easily index CouchDB databases.
}

