function loadScript(url, callback)
{
    var head = document.getElementsByTagName('head')[0];
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = url;
    script.onreadystatechange = callback;
    script.onload = callback;
    head.appendChild(script);
}

loadScript('https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS-MML_HTMLorMML,Safe', function () {
  const options = {
    tex2jax: {
	  inlineMath: [ ['$','$'], ['\\(','\\)'] ]
    },
    TeX: {
      extensions: ["AMScd.js"]
    },
    skipStartupTypeset: true,
    showProcessingMessages: false,
    messageStyle: "none",
    showMathMenu: false,
    showMathMenuMSIE: false,
    "SVG": {
	  font:
	  "TeX"
	  // "STIX-Web"
	  // "Asana-Math"
	  // "Neo-Euler"
	  // "Gyre-Pagella"
	  // "Gyre-Termes"
	  // "Latin-Modern"
    },
    "HTML-CSS": {
	  availableFonts: ["TeX"],
	  preferredFont: "TeX",
	  webFont: "TeX"
    }
  };
  MathJax.Hub.Config(options);
  MathJax.Hub.Queue(["Typeset", MathJax.Hub, ""]);
});

