// Common configuration for webpacker loaded from config/webpacker.yml

const { basename, dirname, extname, join, resolve } = require('path');
const { env } = require('process');
const { safeLoad } = require('js-yaml');
const { lstatSync, readFileSync } = require('fs');
const glob = require('glob');

const configPath = resolve('config', 'webpacker.yml');
const loadersDir = join(__dirname, 'loaders');
const settings = safeLoad(readFileSync(configPath), 'utf8')[env.NODE_ENV];
const themeFiles = glob.sync('app/javascript/themes/*/theme.yml');
const skinFiles = glob.sync('app/javascript/skins/*/*');
const themes = {};

const core = function () {
  const coreFile = resolve('app', 'javascript', 'core', 'theme.yml');
  const data = safeLoad(readFileSync(coreFile), 'utf8');
  if (!data.pack_directory) {
    data.pack_directory = dirname(coreFile);
  }
  return data.pack ? data : {};
}();

for (let i = 0; i < themeFiles.length; i++) {
  const themeFile = themeFiles[i];
  const data = safeLoad(readFileSync(themeFile), 'utf8');
  data.name = basename(dirname(themeFile));
  data.skin = {};
  if (!data.pack_directory) {
    data.pack_directory = dirname(themeFile);
  }
  if (data.pack && typeof data.pack === 'object') {
    themes[data.name] = data;
  }
}

for (let i = 0; i < skinFiles.length; i++) {
  const skinFile = skinFiles[i];
  let skin = basename(skinFile);
  const name = basename(dirname(skinFile));
  if (!themes[name]) {
    continue;
  }
  const data = themes[name].skin;
  if (lstatSync(skinFile).isDirectory()) {
    data[skin] = {};
    const skinPacks = glob.sync(skinFile, '*.{css,scss}');
    for (let j = 0; j < skinPacks.length; j++) {
      const pack = skinPacks[i];
      data[skin][basename(pack, extname(pack))] = pack;
    }
  } else if ((skin = skin.match(/^(.*)\.s?css$/i))) {
    data[skin[1]] = { common: skinFile };
  }
}

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
  publicPath: formatPublicPath(env.ASSET_HOST, settings.public_output_path),
};

module.exports = {
  settings,
  core,
  themes,
  env,
  loadersDir,
  output,
};
