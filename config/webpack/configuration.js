// Common configuration for webpacker loaded from config/webpacker.yml

const { resolve } = require('path');
const { env } = require('process');
const { load } = require('js-yaml');
const { readFileSync } = require('fs');

const configPath = resolve('config', 'webpacker.yml');
const settings = load(readFileSync(configPath), 'utf8')[env.RAILS_ENV || env.NODE_ENV];

const themePath = resolve('config', 'themes.yml');
const themes = load(readFileSync(themePath), 'utf8');

const brandingPath = resolve('config', 'branding.yml');
const branding = load(readFileSync(brandingPath), 'utf8');

const output = {
  path: resolve('public', settings.public_output_path),
  publicPath: `/${settings.public_output_path}/`,
};

module.exports = {
  settings,
  themes,
  env: {
    NODE_ENV: env.NODE_ENV,
    PUBLIC_OUTPUT_PATH: settings.public_output_path,
    APP_LINK: env.APP_LINK || branding.app_link,
    APP_LINK_TEXT: env.APP_LINK_TEXT || branding.app_link_text,
    JOIN_BUTTON_LINK: env.JOIN_BUTTON_LINK || branding.join_button_link,
    JOIN_BUTTON_TEXT: env.JOIN_BUTTON_TEXT || branding.join_button_text,
  },
  output,
};
