import ready from '../ready';

export let assetHost = '';

ready(() => {
  const cdnHost = document.querySelector('meta[name=cdn-host]');
  if (cdnHost) {
    assetHost = cdnHost.content || '';
  }
});
