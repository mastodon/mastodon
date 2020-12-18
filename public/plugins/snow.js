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
    var container = document.createElement("div");
    container.classList.add("snowfall");

    var n = 250 * (screen.width * screen.height) / (1920 * 1080)

    for (var i = 0; i < Math.min(n, 250); i++) {
      var flake = document.createElement("div");
      flake.classList.add("snowflake");
      container.appendChild(flake);
    }

    document.querySelector("body").appendChild(container);
  });
})();
