// Common configuration for webpacker loaded from config/webpacker.yml

const { resolve } = require('path');
const { env } = require('process');
const { safeLoad } = require('js-yaml');
const { readFileSync } = require('fs');

const configPath = resolve('config', 'webpacker.yml');
const settings = safeLoad(readFileSync(configPath), 'utf8')[env.RAILS_ENV || env.NODE_ENV];

const themePath = resolve('config', 'themes.yml');
const themes = safeLoad(readFileSync(themePath), 'utf8');

function removeOuterSlashes(string) {
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

const output = {
  path: resolve('public', settings.public_output_path),
  publicPath: formatPublicPath(env.CDN_HOST, settings.public_output_path),
};

module.exports = {
  settings,
  themes,
  env: {
    CDN_HOST: env.CDN_HOST,
    NODE_ENV: env.NODE_ENV,
  },
  output,
};
