(function() {
  'use strict';

  var ready = function(loaded) {
    if (['interactive', 'complete'].indexOf(document.readyState) !== -1) {
      loaded();
    } else {
      document.addEventListener('DOMContentLoaded', loaded);
    }
  };

  ready(function() {
    var iframes = [];

    window.addEventListener('message', function(e) {
      var data = e.data || {};

      if (data.type !== 'setHeight' || !iframes[data.id]) {
        return;
      }

      iframes[data.id].height = data.height;
    });

    [].forEach.call(document.querySelectorAll('iframe.mastodon-embed'), function(iframe) {
      iframe.scrolling      = 'no';
      iframe.style.overflow = 'hidden';

      iframes.push(iframe);

      var id = iframes.length - 1;

      iframe.onload = function() {
        iframe.contentWindow.postMessage({
          type: 'setHeight',
          id: id,
        }, '*');
      };

      iframe.onload();
    });
  });
})();
