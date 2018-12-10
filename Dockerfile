#
# build container
#
FROM golang:1.10.0-alpine3.7
WORKDIR /go/src/github.com/veritone/redis_exporter/

ADD main.go /go/src/github.com/veritone/redis_exporter/
ADD exporter /go/src/github.com/veritone/redis_exporter/exporter
ADD vendor /go/src/github.com/veritone/redis_exporter/vendor

ARG SHA1
ENV SHA1=$SHA1
ARG TAG
ENV TAG=$TAG
ARG DATE
ENV DATE=$DATE
ARG GITHUB_ACCESS_TOKEN
ENV GITHUB_ACCESS_TOKEN=$GITHUB_ACCESS_TOKEN

RUN apk update && apk add -U build-base git curl libstdc++ ca-certificates
RUN git config --global url."https://${GITHUB_ACCESS_TOKEN}:x-oauth-basic@github.com/".insteadOf "https://github.com/"
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags  " -X main.VERSION=$TAG -X main.COMMIT_SHA1=$SHA1 -X main.BUILD_DATE=$DATE " -a -installsuffix cgo -o redis_exporter .

#
# release container
#
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /bin/
COPY --from=0 /go/src/github.com/veritone/redis_exporter/ .

EXPOSE     9121
ENTRYPOINT [ "/bin/redis_exporter" ]
