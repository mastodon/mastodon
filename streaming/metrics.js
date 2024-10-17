// @ts-check

import metrics from 'prom-client';

/**
 * @typedef StreamingMetrics
 * @property {metrics.Gauge<"type">} connectedClients
 * @property {metrics.Gauge<"type" | "channel">} connectedChannels
 * @property {metrics.Gauge} redisSubscriptions
 * @property {metrics.Counter} redisMessagesReceived
 * @property {metrics.Counter<"type">} messagesSent
 * @property {import('express').RequestHandler<{}>} requestHandler
 */

/**
 *
 * @param {string[]} channels
 * @param {import('pg').Pool} pgPool
 * @returns {StreamingMetrics}
 */
export function setupMetrics(channels, pgPool) {
  // Collect metrics from Node.js
  metrics.collectDefaultMetrics();

  new metrics.Gauge({
    name: 'pg_pool_total_connections',
    help: 'The total number of clients existing within the pool',
    collect() {
      this.set(pgPool.totalCount);
    },
  });

  new metrics.Gauge({
    name: 'pg_pool_idle_connections',
    help: 'The number of clients which are not checked out but are currently idle in the pool',
    collect() {
      this.set(pgPool.idleCount);
    },
  });

  new metrics.Gauge({
    name: 'pg_pool_waiting_queries',
    help: 'The number of queued requests waiting on a client when all clients are checked out',
    collect() {
      this.set(pgPool.waitingCount);
    },
  });

  const connectedClients = new metrics.Gauge({
    name: 'connected_clients',
    help: 'The number of clients connected to the streaming server',
    labelNames: ['type'],
  });

  const connectedChannels = new metrics.Gauge({
    name: 'connected_channels',
    help: 'The number of channels the streaming server is streaming to',
    labelNames: [ 'type', 'channel' ]
  });

  const redisSubscriptions = new metrics.Gauge({
    name: 'redis_subscriptions',
    help: 'The number of Redis channels the streaming server is subscribed to',
  });

  const redisMessagesReceived = new metrics.Counter({
    name: 'redis_messages_received_total',
    help: 'The total number of messages the streaming server has received from redis subscriptions'
  });

  const messagesSent = new metrics.Counter({
    name: 'messages_sent_total',
    help: 'The total number of messages the streaming server sent to clients per connection type',
    labelNames: [ 'type' ]
  });

  // Prime the gauges so we don't loose metrics between restarts:
  redisSubscriptions.set(0);
  connectedClients.set({ type: 'websocket' }, 0);
  connectedClients.set({ type: 'eventsource' }, 0);

  // For each channel, initialize the gauges at zero; There's only a finite set of channels available
  channels.forEach(( channel ) => {
    connectedChannels.set({ type: 'websocket', channel }, 0);
    connectedChannels.set({ type: 'eventsource', channel }, 0);
  });

  // Prime the counters so that we don't loose metrics between restarts.
  // Unfortunately counters don't support the set() API, so instead I'm using
  // inc(0) to achieve the same result.
  redisMessagesReceived.inc(0);
  messagesSent.inc({ type: 'websocket' }, 0);
  messagesSent.inc({ type: 'eventsource' }, 0);

  /**
   * @type {import('express').RequestHandler<{}>}
   */
  const requestHandler = (req, res) => {
    metrics.register.metrics().then((output) => {
      res.set('Content-Type', metrics.register.contentType);
      res.set('Cache-Control', 'private, no-store');
      res.end(output);
    }).catch((err) => {
      req.log.error(err, "Error collecting metrics");
      res.set('Cache-Control', 'private, no-store');
      res.status(500).end();
    });
  };

  return {
    requestHandler,
    connectedClients,
    connectedChannels,
    redisSubscriptions,
    redisMessagesReceived,
    messagesSent,
  };
}
