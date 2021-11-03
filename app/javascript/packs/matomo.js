! function () {
  var mtmDataTag = document.querySelector('[data-matomo-host]')
  var mtmHost = mtmDataTag.dataset.matomoHost
  var mtmSiteId = mtmDataTag.dataset.matomoSiteId

  var _paq = window._paq = window._paq || [];
  /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function () {
    var u = "//" + mtmHost + "/";
    _paq.push(['setTrackerUrl', u + 'matomo.php']);
    _paq.push(['setSiteId', mtmSiteId]);
    var d = document,
      g = d.createElement('script'),
      s = d.getElementsByTagName('script')[0];
    g.async = true;
    g.src = u + 'matomo.js';
    s.parentNode.insertBefore(g, s);
  })();
}()
