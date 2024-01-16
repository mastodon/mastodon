/** @type {import('jest').Config} */
const config = {
  testEnvironment: 'jsdom',
  testPathIgnorePatterns: [
    '<rootDir>/node_modules/',
    '<rootDir>/vendor/',
    '<rootDir>/config/',
    '<rootDir>/log/',
    '<rootDir>/public/',
    '<rootDir>/tmp/',
    '<rootDir>/app/javascript/themes/',
  ],
  setupFilesAfterEnv: ['<rootDir>/app/javascript/mastodon/test_setup.js'],
  collectCoverageFrom: [
    'app/javascript/mastodon/**/*.{js,jsx,ts,tsx}',
    '!app/javascript/mastodon/features/emoji/emoji_compressed.js',
    '!app/javascript/mastodon/service_worker/entry.js',
    '!app/javascript/mastodon/test_setup.js',
  ],
  // Those packages are ESM, so we need them to be processed by Babel
  transformIgnorePatterns: ['/node_modules/(?!(redent|strip-indent)/)'],
  coverageDirectory: '<rootDir>/coverage',
  moduleDirectories: ['node_modules', '<rootDir>/app/javascript'],
  moduleNameMapper: {
    '\\.svg\\?react$': '<rootDir>/app/javascript/__mocks__/svg.js',
  },
};

module.exports = config;
