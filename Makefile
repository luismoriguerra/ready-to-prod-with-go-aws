.PHONY: build clean deploy

build:
	dep ensure -v
	env GOOS=linux go build -ldflags="-s -w" -o bin/hello hello/main.go
	env GOOS=linux go build -ldflags="-s -w" -o bin/world world/main.go

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

build-first-zip:
	GOOS=linux GOARCH=amd64 go build -o  bin/first src/first/main.go
	zip zips/first.zip bin/first

build-dlv:
	GOARCH=amd64 GOOS=linux go build -o debug/dlv github.com/go-delve/delve/cmd/dlv

build-template:
	sls sam export -o template.yml

build-debug:
	env GOOS=linux go build -gcflags='-N -l' -o bin/hello hello/main.go
	env GOOS=linux go build -gcflags='-N -l' -o bin/world world/main.go
	env GOOS=linux go build -gcflags='-N -l' -o bin/first src/first/main.go
	rm -rf .serverless/my-test-go-services.zip
	zip -r .serverless/my-test-go-services.zip ./bin

start-api:
	make build-debug
	sam local start-api --debug

debug-api:
	make build-debug
	sam local start-api -d 5555 --debug --debugger-path ./debug -l ./debug/output.log

debug-hello:
	sam local invoke -d 5555 MyTestGoServicesDevHello <<< "{}" --debug --debugger-path ./debug -l ./debug/output.log

