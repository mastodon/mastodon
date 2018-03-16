module.exports = {
  projects: [
    '<rootDir>/app/javascript/mastodon',
  ],
  testPathIgnorePatterns: [
    '<rootDir>/node_modules/',
    '<rootDir>/vendor/',
    '<rootDir>/config/',
    '<rootDir>/log/',
    '<rootDir>/public/',
    '<rootDir>/tmp/',
  ],
  setupFiles: [
    'raf/polyfill',
  ],
  setupTestFrameworkScriptFile: '<rootDir>/app/javascript/mastodon/test_setup.js',
  collectCoverageFrom: [
    'app/javascript/mastodon/**/*.js',
    '!app/javascript/mastodon/features/emoji/emoji_compressed.js',
    '!app/javascript/mastodon/locales/locale-data/*.js',
    '!app/javascript/mastodon/service_worker/entry.js',
    '!app/javascript/mastodon/test_setup.js',
  ],
  coverageDirectory: '<rootDir>/coverage',
};
