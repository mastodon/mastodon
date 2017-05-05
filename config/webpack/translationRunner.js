/*eslint no-console: "off"*/
const manageTranslations = require('react-intl-translations-manager').default;
const fs = require('fs');

const translationsDirectory = 'app/javascript/mastodon/locales';
const localeFn = /^([a-z]{2,3}(|\-[A-Z]+))\.json$/;
const languages = fs.readdirSync('/home/koala/Workspace/mastodon/app/javascript/mastodon/locales/').reduce((acc, fn) => {
  if (fn.match(localeFn)) {
    acc.push(fn.replace(localeFn, '$1'));
  }
  return acc;
}, []);

manageTranslations({
  messagesDirectory: 'build/messages',
  translationsDirectory,
  detectDuplicateIds: false,
  singleMessagesFile: true,
  languages,
});
