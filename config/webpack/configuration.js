// Common configuration for webpacker loaded from config/webpacker.yml

const { lstatSync, readFileSync } = require('fs');
const { basename, dirname, join, resolve } = require('path');
const { env } = require('process');

const glob = require('glob');
const { load } = require('js-yaml');

const configPath = resolve('config', 'webpacker.yml');
const settings = load(readFileSync(configPath), 'utf8')[env.RAILS_ENV || env.NODE_ENV];
const flavourFiles = glob.sync('app/javascript/flavours/*/theme.yml');
const skinFiles = glob.sync('app/javascript/skins/*/*');
const flavours = {};

flavourFiles.forEach((flavourFile) => {
  const data = load(readFileSync(flavourFile), 'utf8');
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
});

skinFiles.forEach((skinFile) => {
  let skin = basename(skinFile);
  const name = basename(dirname(skinFile));
  if (!flavours[name]) {
    return;
  }
  const data = flavours[name].skin;
  if (lstatSync(skinFile).isDirectory()) {
    data[skin] = {};
    // TODO: more cleanly take the first match
    const skinPacks = glob.sync(join(skinFile, '{common,index,application}.{css,scss}'));
    skinPacks.forEach((pack) => {
      data[skin] = pack;
    });
  } else if ((skin = skin.match(/^(.*)\.s?css$/i))) {
    data[skin[1]] = skinFile;
  }
});

const output = {
  path: resolve('public', settings.public_output_path),
  publicPath: `/${settings.public_output_path}/`,
};

module.exports = {
  settings,
  flavours,
  env: {
    NODE_ENV: env.NODE_ENV,
    PUBLIC_OUTPUT_PATH: settings.public_output_path,
  },
  output,
};
