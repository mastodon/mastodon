// @ts-check

import log from 'npmlog';

const LOG_PREFIX = 'subscriber';

/**
 * @typedef SubscriberOptions
 * @property {import('redis').RedisClientType} redisClient
 */

/**
 * @callback SubscribeListener
 * @param {string} message
 */

export default class Subscriber {

  /**
   * @param {SubscriberOptions} options
   */
  constructor({ redisClient }) {
    /** @type {import('redis').RedisClientType} */
    this.redisClient = redisClient;

    /** @type {Map<string, Set<SubscribeListener>>} */
    this.subs = new Map();
  }

  /**
   * @param {string} message
   * @param {string} channel
   * @returns {void}
   */
  handleRedisMessage = (message, channel) => {
    log.silly(LOG_PREFIX, `New message on channel ${channel}`);

    if (this.subs.has(channel)) {
      for (const listener of this.subs.get(channel)) {
        listener.call(this, message);
      }
    }
  };

  /**
   * @param {string} channel
   * @param {SubscribeListener} listener
   * @returns {void}
   */
  register(channel, listener) {
    log.silly(LOG_PREFIX, `Adding listener for ${channel}`);

    if (this.subs.has(channel)) {
      this.subs.set(channel, new Set());
    }

    if (this.subs.get(channel).size < 1) {
      log.verbose(LOG_PREFIX, `Subscribe ${channel}`);
      this.redisClient.subscribe(channel, this.handleRedisMessage);
    }

    this.subs.get(channel).add(listener);
  }

  /**
   * @param {string} channel
   * @param {SubscribeListener=} listener
   * @returns {void}
   */
  unregister(channel, listener) {
    log.silly(LOG_PREFIX, `Removing listener for ${channel}`);

    if (!this.subs.has(channel)) {
      return;
    }

    if (typeof listener === 'function') {
      this.subs.get(channel).delete(listener);
    }

    if (this.subs.get(channel).size < 1) {
      log.verbose(LOG_PREFIX, `Unsubscribe ${channel}`);
      this.redisClient.unsubscribe(channel);
      this.subs.delete(channel);
    }
  }

}
