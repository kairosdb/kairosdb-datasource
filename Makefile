all: frontend backend

frontend:
	npm install
	./node_modules/.bin/grunt

backend:
	env GOOS=darwin GOARCH=amd64 go build -o ./dist/grafana-kairosdb-datasource_darwin_amd64 ./pkg
	env GOOS=linux GOARCH=amd64 go build -o ./dist/grafana-kairosdb-datasource_linux_amd64 ./pkg

docker:
	docker build -t grafana-kairosdb -f Dockerfile .

clean:
	rm -r ./dist/*
