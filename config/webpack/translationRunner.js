/*eslint no-console: "off"*/
const manageTranslations = require('react-intl-translations-manager').default;
const fs = require('fs');

const argv = require('minimist')(process.argv.slice(2), {
  'boolean': [
    'force',
    'help'
  ],
  'alias': {
    'f': 'force',
    'h': 'help',
  },
});
const translationsDirectory = 'app/javascript/mastodon/locales';
const localeFn = /^([a-z]{2,3}(|\-[A-Z]+))\.json$/;
const reRFC5646 = /^[a-z]{2,3}(|\-[A-Z]+)$/;
const availableLanguages = fs.readdirSync(`${process.cwd()}/${translationsDirectory}`).reduce((acc, fn) => {
  if (fn.match(localeFn)) {
    acc.push(fn.replace(localeFn, '$1'));
  }
  return acc;
}, []);

// print help message
if (argv.help === true) {
  console.log(
`Usage: yarn manage:translations -- [OPTIONS] [LANGUAGES]

Manage javascript translation files in mastodon. Generates and update
translations in translationsDirectory: ${translationsDirectory}

OPTIONS
  -h,--help    show this message
  -f,--force   force using the provided languages. create files if not exists.
               default: false

LANGUAGES
The RFC5646 language tag for the language you want to test or fix. If you want
to input multiple languages, separate them with space.

Available languages:
${availableLanguages}
`);
  process.exit(0);
}

// determine the languages list
const languages = (argv._.length === 0) ? availableLanguages : argv._;

// check if the languages provided are RFC5626 compliant
(function() {
  let invalidLanguages = languages.reduce((acc, language) => {
    if (!language.match(reRFC5646)) {
      acc.push(language);
    }
    return acc;
  }, []);
  if (invalidLanguages.length > 0) {
    console.log(`Error:`);
    for (let language of invalidLanguages) {
      console.error(`* Not RFC5626 name: ${language}`);
    }
    console.log(`\nUse yarn "manage:translations -- --help" for usage information\n`);
    process.exit(1);
  }
})();

// make sure the language exists. Unless force to create locale file.
if (argv.force !== true) {
  let invalidLanguages = languages.reduce((acc, language) => {
    if (availableLanguages.indexOf(language) < 0) {
      acc.push(language);
    }
    return acc;
  }, []);
  if (invalidLanguages.length > 0) {
    console.log(`Error:`);
    for (let language of invalidLanguages) {
      console.error(`* Language not available: ${language}`);
    }
    console.log(`\nIf you want to force creating the language(s) above, please add the --force option.\n`);
    process.exit(1);
  }
}

manageTranslations({
  messagesDirectory: 'build/messages',
  translationsDirectory,
  detectDuplicateIds: false,
  singleMessagesFile: true,
  languages,
});
