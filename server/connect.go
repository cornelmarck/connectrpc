package server

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"strings"
	"time"

	"connectrpc.com/connect"
	v1 "github.com/cornelmarck/connectrpc/gen/proto/v1"
	v1service "github.com/cornelmarck/connectrpc/gen/proto/v1/v1connect"
)

type TestErrorServer struct {
	v1service.UnimplementedEchoServiceHandler
}

func (s *TestErrorServer) EchoUnary(
	ctx context.Context,
	req *connect.Request[v1.EchoUnaryRequest],
) (*connect.Response[v1.EchoUnaryResponse], error) {
	text := req.Msg.GetMessage()

	// The underlying error is exposed to the client as the gRPC error message, so do not include the
	// original error containing internal server details.
	if strings.Contains(text, "internal") {
		originalErr := errors.New("internal error with sensitive details")
		slog.Error("internal error", slog.Any("error", originalErr))
		return nil, connect.NewError(connect.CodeInternal, errors.New("some error occurred"))
	}
	if strings.Contains(text, "invalid") {
		slog.Warn("invalid request")
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("invalid text: %s", text))
	}

	select {
	case <-ctx.Done():
		return nil, ctx.Err()
	case <-time.After(1 * time.Second):
		return connect.NewResponse(&v1.EchoUnaryResponse{
			Message: text,
		}), nil
	}
}
