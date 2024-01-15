build:
	dev-env exec -- sh -c "cd /src/client && elm make src/Main.elm --output ../html/elm.js"

build_debug:
	dev-env exec -- sh -c "cd /src/client && elm make src/Main.elm --debug --output ../html/elm.js"

format:
	dev-env exec -- sh -c "cd /src/client && elm-format --yes src/M* src/U* src/V*"

start_postgres:
	docker run --rm -it --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:16.1

start_server:
	dev-env exec -- sh -c "cd server && PGHOST=host.docker.internal PGPORT=5432 PGDATABASE=postgres PGUSERNAME=postgres PGPASSWORD=postgres node ./main.js"

start_built_server:
	docker pull ghcr.io/mrxk/dbview:main
	export PGHOST=host.docker.internal && \
	export PGPORT=5432 && \
	export PGDATABASE=postgres && \
	export PGUSERNAME=postgres && \
	export PGPASSWORD=postgres && \
	docker run --rm -it -p 8080:8080 -e PGHOST -e PGPORT -e PGDATABASE -e PGUSERNAME -e PGPASSWORD ghcr.io/mrxk/dbview:main