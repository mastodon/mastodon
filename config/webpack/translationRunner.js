const fs = require('fs');
const path = require('path');
const { default: manageTranslations, readMessageFiles } = require('react-intl-translations-manager');

const RFC5646_REGEXP = /^[a-z]{2,3}(?:-(?:x|[A-Za-z]{2,4}))*$/;

const rootDirectory = path.resolve(__dirname, '..', '..');
const externalDefaultMessages = path.resolve(rootDirectory, 'app', 'javascript', 'mastodon', 'locales', 'defaultMessages.json');
const translationsDirectory = path.resolve(rootDirectory, 'app', 'javascript', 'flavours', 'glitch', 'locales');
const messagesDirectory = path.resolve(rootDirectory, 'build', 'messages');
const availableLanguages = fs.readdirSync(translationsDirectory).reduce((languages, filename) => {
  const basename = path.basename(filename, '.json');
  if (RFC5646_REGEXP.test(basename)) {
    languages.push(basename);
  }
  return languages;
}, []);

const testRFC5646 = language => {
  if (!RFC5646_REGEXP.test(language)) {
    throw new Error('Not RFC5646 name');
  }
};

const testAvailability = language => {
  if (!availableLanguages.includes(language)) {
    throw new Error('Not an available language');
  }
};

const validateLanguages = (languages, validators) => {
  const invalidLanguages = languages.reduce((acc, language) => {
    try {
      validators.forEach(validator => validator(language));
    } catch (error) {
      acc.push({ language, error });
    }
    return acc;
  }, []);

  if (invalidLanguages.length > 0) {
    console.error(`
Error: Specified invalid LANGUAGES:
${invalidLanguages.map(({ language, error }) => `* ${language}: ${error.message}`).join('\n')}

Use yarn "manage:translations -- --help" for usage information
`);
    process.exit(1);
  }
};

const usage = `Usage: yarn manage:translations [OPTIONS] [LANGUAGES]

Manage JavaScript translation files in Mastodon. Generates and update translations in translationsDirectory: ${translationsDirectory}

LANGUAGES
The RFC5646 language tag for the language you want to test or fix. If you want to input multiple languages, separate them with space.

Available languages:
${availableLanguages.join(', ')}
`;

const { argv } = require('yargs')
  .usage(usage)
  .option('f', {
    alias: 'force',
    default: false,
    describe: 'force using the provided languages. create files if not exists.',
    type: 'boolean',
  });

// check if message directory exists
if (!fs.existsSync(messagesDirectory)) {
  console.error(`
Error: messagesDirectory not exists
(${messagesDirectory})
Try to run "yarn build:development" first`);
  process.exit(1);
}

// determine the languages list
const languages = (argv._.length > 0) ? argv._ : availableLanguages;

// validate languages
validateLanguages(languages, [
  testRFC5646,
  !argv.force && testAvailability,
].filter(Boolean));

// Override `provideExtractedMessages` to ignore translation strings provided upstream already
const provideExtractedMessages = () => {
  const extractedMessages = readMessageFiles(messagesDirectory);
  const originalExtractedMessages = JSON.parse(fs.readFileSync(externalDefaultMessages, 'utf8'));
  const originalKeys = new Set();

  originalExtractedMessages.forEach(file => {
    file.descriptors.forEach(descriptor => {
      originalKeys.add(descriptor.id)
    });
  });

  extractedMessages.forEach(file => {
    file.descriptors = file.descriptors.filter((descriptor) => !originalKeys.has(descriptor.id));
  });

  return extractedMessages.filter((file) => file.descriptors.length > 0);
};

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
  overrideCoreMethods: {
    provideExtractedMessages,
  },
});
