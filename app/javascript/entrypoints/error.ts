import ready from '../mastodon/ready';

ready(() => {
  const image = document.querySelector<HTMLImageElement>('img');

  if (!image) return;

  image.addEventListener('mouseenter', () => {
    image.src = '/oops.gif';
  });

  image.addEventListener('mouseleave', () => {
    image.src = '/oops.png';
  });
}).catch((e: unknown) => {
  console.error(e);
});
