import ready from '../mastodon/ready';

ready(() => {
  const image = document.querySelector('img');

  image.addEventListener('mouseenter', () => {
    image.src = '/oops.gif';
  });

  image.addEventListener('mouseleave', () => {
    image.src = '/oops.png';
  });
});
