import emojify from './components/emoji'

$(() => {
  $.each($('.entry .content, .entry .status__content, .status__display-name, .display-name, .name, .account__header__content'), (_, content) => {
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

  $('.webapp-btn').on('click', e => {
    console.log(e);

    if (e.button === 0) {
      e.preventDefault();
      window.location.href = $(e.target).attr('href');
    }
  });
});
