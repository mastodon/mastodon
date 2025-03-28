const config = {
  '*': 'prettier --ignore-unknown --write',
  '*.{js,ts}': 'eslint --fix',
  '**/*.ts': () => 'tsc -p tsconfig.json --noEmit',
};

module.exports = config;
