Translating
===========

If you want to localise Mastodon into your language, here is how.

There are two parts to Mastodon, the server and the web client. The translations for the web client are in `app/assets/javascripts/components/locales`. For the server-side, the translations live in `config/locales` and are divided into different files. Here are all the files you’ll need to translate:

| Original file (English) | Location | Description |
|---|---|---|
| [`en.jsx`](/app/assets/javascripts/components/locales/en.jsx) | `app/assets/javascripts/components/locales/en.jsx` | Strings for the web client |
| [`en.yml`](/config/locales/en.yml) | `config/locales/en.yml` | Strings for general use |
| [`simple_form.en.yml`](/config/locales/simple_form.en.yml) | `config/locales/simple_form.en.yml` | Strings for the settings area |
| [`devise.en.yml`](/config/locales/devise.en.yml) | `config/locales/devise.en.yml` | Generic strings for Devise |
| [`doorkeeper.en.yml`](/config/locales/doorkeeper.en.yml) | `config/locales/doorkeeper.en.yml` | Generic strings for Doorkeeper |

## Translating

If you use Github, first clone the Mastodon repository to your account.

1. Duplicate the files in their folder and replace `en` in the filenames by your language’s standard two-letters code ([ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)).
   For instance `simple_form.en.yml` becomes `simple_form.es.yml` in the Spanish translation.
2. Also replace the language code in the first lines of all the files, and the last line of the `.jsx` file.
3. Translate the right-side values from English to your language. Keep the indentation and punctuation.

Since Devise and Doorkeeper are popular libraries, there may already be translation files for your language available on the Internet.

## Declaring the language

The locales are mentioned in several other files. To activate your translation, add your language code to the different lists present in these files:

| File | Location | Comment |
|---|---|---|
| [`index.jsx`](/app/assets/javascripts/components/locales/index.jsx) | `app/assets/javascripts/components/locales/index.jsx` | 2 lines to add |
|[`mastodon.jsx`](/app/assets/javascripts/components/containers/mastodon.jsx) | `app/assets/javascripts/components/containers/mastodon.jsx` | 1 line to add + 1 list to complete |
| [`settings_helper.rb`](/app/helpers/settings_helper.rb) | `app/helpers/settings_helper.rb` | 1 line to add + your language’s name |
| [`application.rb`](/config/application.rb) | `config/application.rb` | 1 list to complete |

## Sending the translation

You can then push the files to git and submit a pull request.

## Testing the translation

Once the pull request is accepted, wait for the code to be deployed on a Mastodon instance. Log-in with your account there, and change the locale in the settings. Browse and use the website. See if everything makes sense in context and if anything seems out of place or breaks the layout. Invite other Mastodon users speaking your language to try it and give feedback. Make changes accordingly and update the translation.

## Updating the translation

Keep an eye on the original English files in `app/assets/javascripts/components/locales` and `config/locales`. When they are updated, pass on the changes to your language files. For new strings, add the new lines to the same position and translate them. Once you’re finished with the updates, you can submit a new pull request.
