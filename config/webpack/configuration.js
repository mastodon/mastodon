// Common configuration for webpacker loaded from config/webpacker.yml

const { basename, dirname, extname, join, resolve } = require('path');
const { env } = require('process');
const { safeLoad } = require('js-yaml');
const { lstatSync, readFileSync } = require('fs');
const glob = require('glob');

const configPath = resolve('config', 'webpacker.yml');
const settings = safeLoad(readFileSync(configPath), 'utf8')[env.RAILS_ENV || env.NODE_ENV];
const flavourFiles = glob.sync('app/javascript/flavours/*/theme.yml');
const skinFiles = glob.sync('app/javascript/skins/*/*');
const flavours = {};

const core = function () {
  const coreFile = resolve('app', 'javascript', 'core', 'theme.yml');
  const data = safeLoad(readFileSync(coreFile), 'utf8');
  if (!data.pack_directory) {
    data.pack_directory = dirname(coreFile);
  }
  return data.pack ? data : {};
}();

for (let i = 0; i < flavourFiles.length; i++) {
  const flavourFile = flavourFiles[i];
  const data = safeLoad(readFileSync(flavourFile), 'utf8');
  data.name = basename(dirname(flavourFile));
  data.skin = {};
  if (!data.pack_directory) {
    data.pack_directory = dirname(flavourFile);
  }
  if (data.locales) {
    data.locales = join(dirname(flavourFile), data.locales);
  }
  if (data.pack && typeof data.pack === 'object') {
    flavours[data.name] = data;
  }
}

for (let i = 0; i < skinFiles.length; i++) {
  const skinFile = skinFiles[i];
  let skin = basename(skinFile);
  const name = basename(dirname(skinFile));
  if (!flavours[name]) {
    continue;
  }
  const data = flavours[name].skin;
  if (lstatSync(skinFile).isDirectory()) {
    data[skin] = {};
    const skinPacks = glob.sync(join(skinFile, '*.{css,scss}'));
    for (let j = 0; j < skinPacks.length; j++) {
      const pack = skinPacks[j];
      data[skin][basename(pack, extname(pack))] = pack;
    }
  } else if ((skin = skin.match(/^(.*)\.s?css$/i))) {
    data[skin[1]] = { common: skinFile };
  }
}

const output = {
  path: resolve('public', settings.public_output_path),
  publicPath: `/${settings.public_output_path}/`,
};

module.exports = {
  settings,
  core,
  flavours,
  env: {
    NODE_ENV: env.NODE_ENV,
    PUBLIC_OUTPUT_PATH: settings.public_output_path,
  },
  output,
};
