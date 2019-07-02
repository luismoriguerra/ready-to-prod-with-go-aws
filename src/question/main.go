package main

import "github.com/aws/aws-lambda-go/lambda"

type Event struct {
	Question string
}

type Response struct {
	Question string
	Answer   string
}

func handler(e Event) (Response, error) {
	return Response{
		Question: e.Question,
		Answer:   "I dont know. " + e.Question,
	}, nil
}

func main() {
	lambda.Start(handler)
}

// sam local invoke MyTestGoServicesDevQuestion -e examples/question/question-event.json  <<< "{}"
// sls invoke local -f question -d '{"Question": "where is my dog?"}'
// sls invoke local -f question --path examples/question/question-event.json
