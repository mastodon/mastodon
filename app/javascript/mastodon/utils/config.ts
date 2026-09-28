import ready from '../ready';

export let assetHost = '';

// oxlint-disable-next-line @typescript-eslint/no-floating-promises
ready(() => {
  const cdnHost = document.querySelector<HTMLMetaElement>(
    'meta[name=cdn-host]',
  );
  if (cdnHost) {
    assetHost = cdnHost.content || '';
  }
});
