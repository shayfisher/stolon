ARG PGVERSION

# base build image
FROM golang:1.14-buster AS build_base

WORKDIR /stolon

# only copy go.mod and go.sum
COPY go.mod .
COPY go.sum .

RUN go mod download

#######
####### Build the stolon binaries
#######
FROM build_base AS builder

# copy all the sources
COPY . .

RUN make

#######
####### Build the final image
#######
FROM postgres:$PGVERSION

RUN apt-get install postgresql-12 libxml2- -y && useradd -ms /bin/bash stolon

EXPOSE 5432

# copy the agola-web dist
COPY --from=builder /stolon/bin/ /usr/local/bin

RUN chmod +x /usr/local/bin/stolon-keeper /usr/local/bin/stolon-sentinel /usr/local/bin/stolon-proxy /usr/local/bin/stolonctl
