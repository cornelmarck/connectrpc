FROM golang:1.25-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o connectserver ./cmd/connectserver

# Use a minimal image for the final binary
FROM alpine:latest
WORKDIR /root/

COPY --from=builder /app/connectserver ./

# Not used for kubernetes
EXPOSE 8080

# Command to run
CMD ["./connectserver"]