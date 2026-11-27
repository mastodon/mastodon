import { defineConfig } from 'oxlint';

import config from '../oxlint.config.mts';

export default defineConfig({
  extends: [config],
  env: {
    node: true,
  },
  rules: {
    'no-delete-var': 'off',
    'import/extensions': 'off',
  },
});
