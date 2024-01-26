# Dockerfile for building the OpenTelemetry Collector using OCB
# https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder
FROM golang:latest as build

ARG TARGETARCH

# ARG OBSERVABILITY_BACKEND can be adjusted in the build command
# to configure a different backend. The default is "default" which
# sends telemetry data to the OTLP endpoint configured in
# otelcol-config.yml.
ARG OBSERVABILITY_BACKEND=default
ARG BUILDER_VERSION=0.93.0

RUN curl -L -o /builder https://github.com/open-telemetry/opentelemetry-collector/releases/download/cmd%2Fbuilder%2Fv${BUILDER_VERSION}/ocb_${BUILDER_VERSION}_linux_${TARGETARCH}
RUN chmod +x /builder
WORKDIR /build

# Copy the manifest file for the selected backend
COPY ./${OBSERVABILITY_BACKEND}_manifest.yml ./manifest.yml
ENV GOARCH=$TARGETARCH
ENV CGO_ENABLED=0
RUN /builder --config ./manifest.yml --output-path /build/_build
RUN ls /build/_build

FROM alpine:3.19 as certs
RUN apk --update add ca-certificates

FROM alpine

ARG USER_UID=10001
USER ${USER_UID}

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build --chmod=755 /build/_build/otelcol /otelcol
ENTRYPOINT ["/otelcol"]
EXPOSE 4317 4318
