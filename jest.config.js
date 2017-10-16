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
};
