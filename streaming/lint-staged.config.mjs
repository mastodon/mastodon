const config = {
  '*.{js,ts}': 'oxlint --fix',
  '**/*.ts': () => 'tsc -p tsconfig.json --noEmit',
};

export default config;
