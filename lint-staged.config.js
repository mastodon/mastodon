const config = {
  '*': 'prettier --ignore-unknown --write',
  'Capfile|Gemfile|*.{rb,ruby,ru,rake}': 'bin/rubocop --force-exclusion -a',
  '*.{js,jsx,ts,tsx}': 'eslint --fix',
  '*.{css,scss}': 'stylelint --fix',
  '*.haml': 'bin/haml-lint -a',
  '**/*.ts?(x)': () => 'tsc -p tsconfig.json --noEmit',
};

module.exports = config;
