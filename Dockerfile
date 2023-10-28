#
# Build Stage
#

FROM    golang:latest as build

ENV     CGO_ENABLED=0

WORKDIR /go/bin

COPY    . .

RUN     go get ./...                            && \
        go build -o loki-test-app ./cmd/main.go

#
# Final Stage
#

FROM    scratch as final

COPY    --from=build /go/bin/loki-test-app ./

CMD     ["/loki-test-app"]