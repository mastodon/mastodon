// @ts-check

const allowedPrefixes = (document.currentScript && document.currentScript.tagName.toUpperCase() === 'SCRIPT' && document.currentScript.dataset.allowedPrefixes) ? document.currentScript.dataset.allowedPrefixes.split(' ') : [];

(function () {
  'use strict';

  /**
   * @param {() => void} loaded
   */
  var ready = function (loaded) {
    if (document.readyState === 'complete') {
      loaded();
    } else {
      document.addEventListener('readystatechange', function () {
        if (document.readyState === 'complete') {
          loaded();
        }
      });
    }
  };

  /**
   * @param {Map} map
   */
  var generateId = function (map) {
    var id = 0, failCount = 0, idBuffer = new Uint32Array(1);

    while (id === 0 || map.has(id)) {
      id = crypto.getRandomValues(idBuffer)[0];
      failCount++;

      if (failCount > 100) {
        // give up and assign (easily guessable) unique number if getRandomValues is broken or no luck
        id = -(map.size + 1);
        break;
      }
    }

    return id;
  };

  ready(function () {
    /** @type {Map<number, HTMLQuoteElement | HTMLIFrameElement>} */
    var embeds = new Map();

    window.addEventListener('message', function (e) {
      var data = e.data || {};

      if (typeof data !== 'object' || data.type !== 'setHeight' || !embeds.has(data.id)) {
        return;
      }

      var embed = embeds.get(data.id);

      if (embed instanceof HTMLIFrameElement) {
        embed.height = data.height;
      }

      if (embed instanceof HTMLQuoteElement) {
        var iframe = embed.querySelector('iframe');

        if (!iframe || ('source' in e && iframe.contentWindow !== e.source)) {
          return;
        }

        iframe.height = data.height;

        var placeholder = embed.querySelector('a');

        if (!placeholder) return;

        embed.removeChild(placeholder);
      }
    });

    // Legacy embeds
    document.querySelectorAll('iframe.mastodon-embed').forEach(iframe => {
      var id = generateId(embeds);

      embeds.set(id, iframe);

      iframe.allow = 'fullscreen';
      iframe.sandbox = 'allow-scripts allow-same-origin allow-popups';
      iframe.style.border = 0;
      iframe.style.overflow = 'hidden';
      iframe.style.display = 'block';

      iframe.onload = function () {
        iframe.contentWindow.postMessage({
          type: 'setHeight',
          id: id,
        }, '*');
      };

      iframe.onload(); // In case the script is executing after the iframe has already loaded
    });

    // New generation of embeds
    document.querySelectorAll('blockquote.mastodon-embed').forEach(container => {
      var id = generateId(embeds);

      embeds.set(id, container);

      var iframe = document.createElement('iframe');
      var embedUrl = new URL(container.getAttribute('data-embed-url'));

      if (embedUrl.protocol !== 'https:' && embedUrl.protocol !== 'http:') return;
      if (allowedPrefixes.every((allowedPrefix) => !embedUrl.toString().startsWith(allowedPrefix))) return;

      iframe.src = embedUrl.toString();
      iframe.width = container.clientWidth;
      iframe.height = 0;
      iframe.allow = 'fullscreen';
      iframe.sandbox = 'allow-scripts allow-same-origin allow-popups';
      iframe.style.border = 0;
      iframe.style.overflow = 'hidden';
      iframe.style.display = 'block';

      iframe.onload = function () {
        iframe.contentWindow.postMessage({
          type: 'setHeight',
          id: id,
        }, '*');
      };

      container.appendChild(iframe);
    });
  });
})();
