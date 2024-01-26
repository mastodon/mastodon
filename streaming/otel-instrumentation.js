const {getNodeAutoInstrumentations} = require('@opentelemetry/auto-instrumentations-node');
const {OTLPMetricExporter} = require('@opentelemetry/exporter-metrics-otlp-http');
const {OTLPTraceExporter} = require('@opentelemetry/exporter-trace-otlp-http');
const {containerDetector} = require('@opentelemetry/resource-detector-container');
const {envDetector, hostDetector, osDetector, processDetector} = require('@opentelemetry/resources');
const {PeriodicExportingMetricReader} = require('@opentelemetry/sdk-metrics');
const opentelemetry = require('@opentelemetry/sdk-node');

const sdk = new opentelemetry.NodeSDK({
  traceExporter: new OTLPTraceExporter(),
  instrumentations: [
    getNodeAutoInstrumentations()
  ],
  metricReader: new PeriodicExportingMetricReader({
    exporter: new OTLPMetricExporter(),
  }),
  resourceDetectors: [
    containerDetector,
    envDetector,
    hostDetector,
    osDetector,
    processDetector
  ],
});

sdk.start();
