import { createClient } from "./redis.js";

/**
 * @callback MessageCallback
 * @param {any} message json of the message
 * @returns {void}
 */

export class PubSubManager {
  /**
   *
   * @param {import('./redis.js').RedisConfiguration} redisConfig
   * @param {import('pino').Logger} logger
   * @param {import('./metrics.js').StreamingMetrics} metrics
   */
  constructor(redisConfig, logger, metrics) {
    this.redisConfig = redisConfig;
    this.logger = logger.child({ module: 'PubSubManager' });
    this.metrics = metrics;

    /**
     * @type {Map<string, MessageCallback[]>}
     */
    this.subscriptions = new Map();

    this.redis = createClient(this.redisConfig);
    this.redis.on('message', this._handleMessage.bind(this));
  }

  /**
   * @param {string} channel
   * @param {MessageCallback} callback
   * @returns {Promise<void>}
   */
  async subscribe(channel, callback) {
    if (this.subscriptions.has(channel)) {
      const callbacks = this.subscriptions.get(channel);
      callbacks.push(callback);
      this.subscriptions.set(channel, callbacks);

      return;
    }

    this.subscriptions.set(channel, [ callback ]);

    const prefixedChannel = `${this.redisConfig.redisPrefix}${channel}`;

    this.logger.debug(`Subscribe ${prefixedChannel}`);

    await this.redis.subscribe(prefixedChannel, (err, count) => {
      if (err) {
        this.logger.error(`Error subscribing to ${prefixedChannel}`);
      } else if (typeof count === 'number') {
        this.metrics.redisSubscriptions.set(count);
      }
    });
  }

  /**
   * @param {string} channel
   * @param {MessageCallback} callback
   * @returns {Promise<void>}
   */
  async unsubscribe(channel, callback) {
    if (!this.subscriptions.has(channel)) {
      return;
    }

    const callbacks = this.subscriptions.get(channel) ?? [];
    const newCallbacks = callbacks.filter(item => item !== callback);

    if (newCallbacks.length > 0) {
      this.subscriptions.set(channel, newCallbacks);
    } else {
      this.subscriptions.delete(channel);

      const prefixedChannel = `${this.redisConfig.redisPrefix}${channel}`;

      this.logger.debug(`Unsubscribe ${prefixedChannel}`);
      await this.redis.unsubscribe(prefixedChannel, (err, count) => {
        if (err) {
          this.logger.error(`Error unsubscribing to ${prefixedChannel}`);
        } else if (typeof count === 'number') {
          this.metrics.redisSubscriptions.set(count);
        }
      });
    }
  }

  /**
   * @param {string} prefixedChannel
   * @param {string} message
   * @returns {void}
   */
  _handleMessage(prefixedChannel, message) {
    this.metrics.redisMessagesReceived.inc();
    this.logger.debug(`New message on channel ${prefixedChannel}`);

    const channel = prefixedChannel.slice(this.redisConfig.redisPrefix.length);
    const callbacks = this.subscriptions.get(channel) ?? [];

    if (callbacks.length === 0) {
      return;
    }

    const json = this._parseMessage(message);

    if (!json) {
      return;
    }

    if (typeof json !== 'object' || Array.isArray(json)) {
      this.logger.error({ json }, "Received unexpected message via redis pubsub");
      return;
    }

    // FIXME: Support async/await for callbacks:
    for (let callback of callbacks) {
      try {
        callback(json);
      } catch (err) {
        this.logger.error({ err, channel, json }, `Error processing callback for message on channel ${channel}`);
      }
    }
  }

  /**
   *
   * @param {string} message
   * @returns {any|undefined}
   */
  _parseMessage(message) {
    try {
      return JSON.parse(message);
    } catch (err) {
      this.logger.error({ err, message }, `Error parsing message from redis`);

      return undefined;
    }
  }
}
