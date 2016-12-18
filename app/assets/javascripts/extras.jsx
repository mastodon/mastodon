import emojify from './components/emoji'

$(() => {
  $.each($('.entry .content, .entry .status__content, .display-name, .name, .account__header__content'), (_, content) => {
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

  $('.media-spoiler').on('click', e => {
    $(e.target).hide();
  });
});
