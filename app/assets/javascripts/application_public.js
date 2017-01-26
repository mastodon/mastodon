//= require jquery
//= require jquery_ujs
//= require extras
//= require best_in_place

function blurAfterDelay(el){
  setTimeout(function(_el){
    $(_el).blur();
  }, 100, el);
}

$(function () {
  $(".best_in_place").best_in_place();

  // settings/blocks extras

  $('.checklist_outer #select_all').on('click', function() {
    blurAfterDelay(this);
    $(".checklist_outer .checklist_item input[type='checkbox']").prop("checked", true);
  });
  $('.checklist_outer #deselect_all').on('click', function() {
    blurAfterDelay(this);
    $(".checklist_outer .checklist_item input[type='checkbox']").prop("checked", false);
  });
});
