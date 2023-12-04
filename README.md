# DBView

Do not use this. It is experimental and woefully insecure. The server portion of
this project is similar to `kubectl proxy`.

The image built from this repo starts a server that will connect to the Postgres
database identified in the following environment variables.

* `PGHOST`
* `PGPORT`
* `PGDATABASE`
* `PGUSERNAME` or `PGUSER`
* `PGPASSWORD`
* `PGIDLE_TIMEOUT`
* `PGCONNECT_TIMEOUT`

It will then serve an endpoint at `/postgres` that accepts a POST request with a
body that is a JSON object with a single field, `query`. The value of that field
will be submitted to Postgres as is. The results will be returned as a JSON
object with

* a `count` field that is the number of rows returned
* an optional `columns` field that is an array of the column names of the
  returned result, if any.
* an optional `rows` field that is an array of arrays, one for each row of the
  returned result, if any.

The root of the server is an html page with a query field and a place to output
results.  It allows any query to be executed. Additional queries can be added by
clicking the `add` button.  Queries can be removed by clicking the `x` beside
the query. There is also a `watch` checkbox that will cause the query to be
re-executed after the numbe of sleep seconds specified.

It is built using the following

* https://elm-lang.org/
* https://nodejs.org/
* https://github.com/porsager/postgres
