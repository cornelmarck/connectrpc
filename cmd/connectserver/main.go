package main

import (
	"log/slog"
	"net/http"

	"connectrpc.com/connect"
	v1connect "github.com/cornelmarck/connectrpc/gen/proto/v1/v1connect"
	v1server "github.com/cornelmarck/connectrpc/server"

	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
)

func main() {
	server := &v1server.TestErrorServer{}
	mux := http.NewServeMux()
	path, handler := v1connect.NewEchoServiceHandler(server,
		connect.WithInterceptors(
			v1server.LoggingInterceptor(),
		),
	)
	mux.Handle(path, handler)

	slog.Info("starting server")
	http.ListenAndServe(
		"localhost:8080",
		// Use h2c so we can serve HTTP/2 without TLS.
		h2c.NewHandler(mux, &http2.Server{}),
	)
}
