import emojify from 'mastodon/emoji';
import { length } from 'stringz';
import { default as dateFormat } from 'date-fns/format';
import distanceInWordsStrict from 'date-fns/distance_in_words_strict';

window.jQuery = window.$ = require('jquery');
require('jquery-ujs');
require.context('../images/', true);

const parseFormat = (format) => format.replace(/%(\w)/g, (_, modifier) => {
  switch (modifier) {
  case '%':
    return '%';
  case 'a':
    return 'ddd';
  case 'A':
    return 'ddd';
  case 'b':
    return 'MMM';
  case 'B':
    return 'MMMM';
  case 'd':
    return 'DD';
  case 'H':
    return 'HH';
  case 'I':
    return 'hh';
  case 'l':
    return 'H';
  case 'm':
    return 'M';
  case 'M':
    return 'mm';
  case 'p':
    return 'A';
  case 'S':
    return 'ss';
  case 'w':
    return 'd';
  case 'y':
    return 'YY';
  case 'Y':
    return 'YYYY';
  default:
    return `%${modifier}`;
  }
});

$(() => {
  $.each($('.emojify'), (_, content) => {
    const $content = $(content);
    $content.html(emojify($content.html()));
  });

  $('time[data-format]').each((_, content) => {
    const $content = $(content);
    const format = parseFormat($content.data('format'));
    const formattedDate = dateFormat($content.attr('datetime'), format);
    $content.text(formattedDate);
  });

  $('time.time-ago').each((_, content) => {
    const $content = $(content);
    const timeAgo = distanceInWordsStrict(new Date(), $content.attr('datetime'), { addSuffix: true });
    $content.text(timeAgo);
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
    if (e.button === 0) {
      e.preventDefault();
      window.location.href = $(e.target).attr('href');
    }
  });

  $('.status__content__spoiler-link').on('click', e => {
    e.preventDefault();
    const contentEl = $(e.target).parent().parent().find('div');

    if (contentEl.is(':visible')) {
      contentEl.hide();
      $(e.target).parent().attr('style', 'margin-bottom: 0');
    } else {
      contentEl.show();
      $(e.target).parent().attr('style', null);
    }
  });

  $('.account_display_name').on('input', e => {
    $('.name-counter').text(30 - length($(e.target).val()));
  });

  $('.account_note').on('input', e => {
    $('.note-counter').text(160 - length($(e.target).val()));
  });
});
