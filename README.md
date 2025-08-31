# connectrpc

Based on:
https://connectrpc.com/docs/go/getting-started/

Invoke the server:

HTTP/1:
```
curl \
    --header "Content-Type: application/json" \
    --data '{"message": "Hello world!"}' \
    http://localhost:8080/proto.v1.EchoService/EchoUnary
```

gRPC:
```
bin/grpcurl \
    -protoset <(bin/buf build -o -) -plaintext \
    -d '{"message": "hello world!"}' \
    localhost:8080 proto.v1.EchoService/EchoUnary
```