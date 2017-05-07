/*eslint no-console: "off"*/
const manageTranslations = require('react-intl-translations-manager').default;
const fs = require('fs');

const testRFC5626 = function (reRFC5646) {
  return function (language) {
    if (!language.match(reRFC5646)) {
      throw new Error('Not RFC5626 name');
    }
  }
}

const testAvailability = function (availableLanguages) {
  return function (language) {
    if ((argv.force !== true) && availableLanguages.indexOf(language) < 0) {
      throw new Error('Not an available language');
    }
  }
}

const validateLanguages = function (languages, validators) {
  let invalidLanguages = languages.reduce((acc, language) => {
    try {
      for (let validator of validators) {
        validator(language);
      }
    } catch (error) {
      acc.push({
        language,
        error,
      });
    }
    return acc;
  }, []);

  if (invalidLanguages.length > 0) {
    console.log(`\nError: Specified invalid LANGUAGES:`);
    for (let {language, error} of invalidLanguages) {
      console.error(`* ${language}: ${error}`);
    }
    console.log(`\nUse yarn "manage:translations -- --help" for usage information\n`);
    process.exit(1);
  }
}

const printHelpMessages = function () {
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
}

// parse arguments
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
const messagesDirectory = 'build/messages';
const localeFn = /^([a-z]{2,3}(|\-[A-Z]+))\.json$/;
const reRFC5646 = /^[a-z]{2,3}(|\-[A-Z]+)$/;
const availableLanguages = fs.readdirSync(`${process.cwd()}/${translationsDirectory}`).reduce((acc, fn) => {
  if (fn.match(localeFn)) {
    acc.push(fn.replace(localeFn, '$1'));
  }
  return acc;
}, []);

// print help message
if (argv.help) {
  printHelpMessages();
  process.exit(0);
}

// check if message directory exists
if (!fs.existsSync(`${process.cwd()}/${messagesDirectory}`)) {
  console.error(`\nError: messageDirectory not exists\n(${process.cwd()}/${messagesDirectory})\n`);
  console.error(`Try to run "yarn build:development" first`);
  process.exit(1);
}

// determine the languages list
const languages = (argv._.length === 0) ? availableLanguages : argv._;

// validate languages
validateLanguages(languages, [
  testRFC5626(reRFC5646),
  testAvailability(availableLanguages),
]);

// manage translations
manageTranslations({
  messagesDirectory,
  translationsDirectory,
  detectDuplicateIds: false,
  singleMessagesFile: true,
  languages,
  jsonOptions: {
    trailingNewline: true,
  },
});
