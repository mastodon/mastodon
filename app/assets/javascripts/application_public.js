//= require jquery2
//= require jquery_ujs
//= require extras
//= require best_in_place
//= require local_time

$(function () {
  $(".best_in_place").best_in_place();

  const highlightCode = require('./components/highlight-code').default;
  $("code").each((idx, el) => {
    el.outerHTML = highlightCode(el.outerHTML);
  });
});
