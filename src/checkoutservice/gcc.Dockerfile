# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:1.15-alpine as builder
RUN apk add --no-cache ca-certificates git gcc gcc-go musl-dev
WORKDIR /src

# restore dependencies
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -compiler gccgo -buildmode=exe -gccgoflags -g -o /checkoutservice .

FROM alpine:3.14 as release
WORKDIR /src
RUN apk add --no-cache libgo ca-certificates gcc-go musl-dev
COPY --from=builder /checkoutservice /src/checkoutservice
RUN GRPC_HEALTH_PROBE_VERSION=v0.3.6 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe
EXPOSE 5050
ENTRYPOINT ["/src/checkoutservice"]
