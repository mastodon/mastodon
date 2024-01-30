# Dockerfile for building the OpenTelemetry Collector using OCB
# https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder
FROM golang:latest as build

ARG TARGETARCH

# ARG TELEMETRY_BACKEND can be adjusted in the build command
# to configure a different backend. The default is "default" which
# sends telemetry data to the OTLP endpoint configured in
# otelcol-config.yml.
ARG TELEMETRY_BACKEND=default
ARG BUILDER_VERSION=0.93.0

RUN curl -L -o /builder https://github.com/open-telemetry/opentelemetry-collector/releases/download/cmd%2Fbuilder%2Fv${BUILDER_VERSION}/ocb_${BUILDER_VERSION}_linux_${TARGETARCH}
RUN chmod +x /builder
WORKDIR /build

# Copy the manifest and config file for the selected backend
COPY ./manifests/${TELEMETRY_BACKEND}_manifest.yml ./manifest.yml
COPY ./configs/${TELEMETRY_BACKEND}_config.yml ./otelcol-config.yml
ENV GOARCH=$TARGETARCH
ENV CGO_ENABLED=0
RUN /builder --config ./manifest.yml --output-path /build/_build

FROM alpine:3.19 as certs
RUN apk --update add ca-certificates

FROM alpine

ARG USER_UID=10001
USER ${USER_UID}

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build --chmod=755 /build/_build/otelcol /otelcol
COPY --from=build /build/otelcol-config.yml /etc/otelcol-config.yml
ENTRYPOINT ["/otelcol", "--config=/etc/otelcol-config.yml"]
EXPOSE 4317 4318
