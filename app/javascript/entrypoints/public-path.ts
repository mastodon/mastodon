// Dynamically set webpack's loading path depending on a meta header, in order
// to share the same assets regardless of instance configuration.
// See https://webpack.js.org/guides/public-path/#on-the-fly

function removeOuterSlashes(string: string) {
  return string.replace(/^\/*/, '').replace(/\/*$/, '');
}

function formatPublicPath(host = '', path = '') {
  let formattedHost = removeOuterSlashes(host);
  if (formattedHost && !/^http/i.test(formattedHost)) {
    formattedHost = `//${formattedHost}`;
  }
  const formattedPath = removeOuterSlashes(path);
  return `${formattedHost}/${formattedPath}/`;
}

const cdnHost = document.querySelector<HTMLMetaElement>('meta[name=cdn-host]');

__webpack_public_path__ = formatPublicPath(
  cdnHost ? cdnHost.content : '',
  process.env.PUBLIC_OUTPUT_PATH,
);
