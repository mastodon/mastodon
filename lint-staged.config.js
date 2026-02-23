const config = {
  '*': 'oxfmt --no-error-on-unmatched-pattern',
  'Gemfile|*.{rb,ruby,ru,rake}': 'bin/rubocop --force-exclusion -a',
  '*.{js,jsx,ts,tsx}': 'eslint --fix',
  '*.{css,scss}': 'stylelint --fix',
  '*.haml': 'bin/haml-lint -a',
  '**/*.ts?(x)': () => 'tsc -p tsconfig.json --noEmit',
  'app/javascript/**/*.{js,jsx,ts,tsx}': () => [
    `yarn i18n:extract`,
    'git diff --exit-code app/javascript/mastodon/locales/en.json',
  ],
};

module.exports = config;
