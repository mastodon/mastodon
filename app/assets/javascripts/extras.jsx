import emojify from './components/emoji'

$(() => {
  $.each($('.emojify'), (_, content) => {
    const $content = $(content);
    $content.html(emojify($content.html()));
  });

  $('.video-player video').on('click', e => {
    if (e.target.paused) {
      e.target.play();
    } else {
      e.target.pause();
    }
  });

  $.each($('.spoiler'), (_, content) => {
    $(content).on('click', e => {
      var hasClass = $(content).hasClass('spoiler-on');
      if (hasClass || e.target === content) {
        e.preventDefault();
        $(content).siblings(".spoiler").andSelf().toggleClass('spoiler-on', !hasClass);
      }
    });
  });

  $('.media-spoiler').on('click', e => {
    $(e.target).hide();
  });

  $('.webapp-btn').on('click', e => {
    if (e.button === 0) {
      e.preventDefault();
      window.location.href = $(e.target).attr('href');
    }
  });
});
