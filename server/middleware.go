package server

import (
	"context"
	"log/slog"

	"connectrpc.com/connect"
	"github.com/google/uuid"
	slogcontext "github.com/veqryn/slog-context"
)

const (
	CorrelationIDHeader = "X-Correlation-ID"
	CorrelationIDKey    = "correlation_id"
)

func LoggingInterceptor() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			// Fetch the correlation ID from headers if exists, otherwise create new one.
			correlationID := req.Header().Get(CorrelationIDHeader)
			if correlationID == "" {
				correlationID = uuid.NewString()
			}
			ctx = slogcontext.Prepend(ctx, slog.String("correlation_id", correlationID))

			slog.InfoContext(ctx,
				"incoming request started",
				slog.String("procedure", req.Spec().Procedure),
			)

			res, err := next(ctx, req)
			if err != nil {
				slog.ErrorContext(ctx, "incoming request error", slog.String("error", err.Error()))
			} else {
				slog.InfoContext(ctx, "incoming request ended")
			}

			return res, err
		}
	}
}
