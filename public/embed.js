// @ts-check

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

  ready(function () {
    /** @type {Map<number, HTMLQuoteElement>} */
    var embeds = new Map();

    window.addEventListener('message', function (e) {
      var data = e.data || {};

      if (typeof data !== 'object' || data.type !== 'setHeight' || !embeds.has(data.id)) {
        return;
      }

      var container = embeds.get(data.id);

      if (!container) return;

      var iframe = container.querySelector('iframe');

      if (!iframe || ('source' in e && iframe.contentWindow !== e.source)) {
        return;
      }

      iframe.height = data.height;

      var placeholder = container.querySelector('a');

      if (!placeholder) return;

      container.removeChild(placeholder);
    });

    document.querySelectorAll('blockquote.mastodon-embed').forEach(container => {
      // Select unique id for each iframe
      var id = 0, failCount = 0, idBuffer = new Uint32Array(1);

      while (id === 0 || embeds.has(id)) {
        id = crypto.getRandomValues(idBuffer)[0];
        failCount++;

        if (failCount > 100) {
          // give up and assign (easily guessable) unique number if getRandomValues is broken or no luck
          id = -(embeds.size + 1);
          break;
        }
      }

      embeds.set(id, container);

      var iframe = document.createElement('iframe');
      var embedUrl = new URL(container.getAttribute('data-embed-url'));

      if (embedUrl.protocol !== 'https:') return;

      iframe.src = embedUrl.toString();
      iframe.width = container.clientWidth;
      iframe.height = 0;
      iframe.scrolling = 'no';
      iframe.allowfullscreen = true;
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
