import emojify from './components/emoji'

$(() => {
  $.each($('.entry .content, .name, .account__header__content'), (_, content) => {
    const $content = $(content);
    $content.html(emojify($content.html()));
  });
});
