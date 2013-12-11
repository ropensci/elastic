\name{elastic_stop}
\alias{elastic_stop}
\title{Stop indexing a CouchDB database using Elasticsearch.}
\usage{
elastic_stop(dbname, endpoint = "http://localhost", port = 9200)
}
\arguments{
  \item{dbname}{Database name. (charcter)}

  \item{endpoint}{the endpoint, defaults to localhost
  (http://127.0.0.1)}

  \item{port}{port to connect to, defaults to 5984}
}
\description{
Stop indexing a CouchDB database using Elasticsearch.
}
\details{
The function returns a message 'elastic river stopped'.
This function stops elasticsearch from indexing the
database in the dbname parameter. You may want stop
indexing e.g., if you started indexing a database that you
didn't mean to start indexing.
}
\examples{
\dontrun{
elastic_stop(dbname = "ggggg")
}
}

