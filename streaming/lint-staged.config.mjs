const config = {
  '*.{js,ts}': 'eslint --fix',
  '**/*.ts': () => 'tsc -p tsconfig.json --noEmit',
};

export default config;
