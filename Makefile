.PHONY: build clean deploy

build:
	dep ensure -v
	env GOOS=linux go build -ldflags="-s -w" -o bin/hello hello/main.go
	env GOOS=linux go build -ldflags="-s -w" -o bin/world world/main.go

build-debug:
	GOARCH=amd64 GOOS=linux go build -o debug/dlv github.com/go-delve/delve/cmd/dlv

build-test:
	env GOOS=linux go build -gcflags='-N -l' -o bin/hello hello/main.go
	env GOOS=linux go build -gcflags='-N -l' -o bin/world world/main.go
	zip zips/hello.zip bin/hello
	zip zips/world.zip bin/world

start-debug:
	make build-test
	sam local start-api -d 5555 --debug --debugger-path ./debug --log-file ./debug/output.log

clean:
	rm -rf ./bin ./vendor Gopkg.lock

deploy: clean build
	sls deploy --verbose

sls-invoke:
	env GOOS=linux go build -gcflags='-N -l' -o bin/hello hello/main.go
	sls invoke local -f hello

sam-invoke:
	GOARCH=amd64 GOOS=linux go build -gcflags='-N -l' -o bin/hello hello/main.go
	GOARCH=amd64 GOOS=linux go build -o debug/dlv github.com/go-delve/delve/cmd/dlv
	sam local invoke --debug MyTestGoServicesDevHello <<< "{}"

build-zip:
	GOOS=linux GOARCH=amd64 go build -o  bin/first src/first/main.go
	zip zips/first.zip bin/first
