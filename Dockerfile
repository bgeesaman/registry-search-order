FROM golang:alpine AS build
RUN apk --no-cache add build-base git bzr mercurial gcc
RUN adduser -D -g '' h0nX0r
RUN mkdir /src
ADD main.go /src
RUN cd /src && go build -o h0nX0r && chmod +x h0nX0r

FROM scratch
WORKDIR /
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /src/h0nX0r /
USER h0nX0r
ENTRYPOINT ["./h0nX0r"]
