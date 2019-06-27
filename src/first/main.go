package main

import (
	"bytes"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type Event struct {
	Username string
}
type Response events.APIGatewayProxyResponse

func handler(request events.APIGatewayProxyRequest) (Response, error) {
	var username = request.QueryStringParameters["Username"]
	html := fmt.Sprintf("Hello %s from lambda", username)

	var buf bytes.Buffer

	body, err := json.Marshal(html)
	if err != nil {
		return Response{StatusCode: 404}, err
	}

	json.HTMLEscape(&buf, body)

	resp := Response{
		StatusCode:      200,
		IsBase64Encoded: false,
		Body:            buf.String(),
		Headers: map[string]string{
			"Content-Type": "text/html; charset=UTF-8",
		},
	}

	return resp, nil
}

func main() {
	lambda.Start(handler)
}
