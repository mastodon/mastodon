import { useCallback, useState } from 'react';
import type { ChangeEventHandler, FC } from 'react';

import type { IntlShape } from 'react-intl';
import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { createSelector } from '@reduxjs/toolkit';
import type { List as ImmutableList } from 'immutable';

import type { SelectItem } from '@/mastodon/components/dropdown_selector';
import { Select } from '@/mastodon/components/form_fields';
import type { RootState } from '@/mastodon/store';
import { useAppSelector } from '@/mastodon/store';

import { Section } from './section';

const messages = defineMessages({
  rules: { id: 'about.rules', defaultMessage: 'Server rules' },
  defaultLocale: { id: 'about.default_locale', defaultMessage: 'Default' },
});

interface RulesSectionProps {
  isLoading?: boolean;
}

interface BaseRule {
  text: string;
  hint: string;
}

interface Rule extends BaseRule {
  id: string;
  translations?: Record<string, BaseRule>;
}

function getDefaultSelectedLocale(
  currentUiLocale: string,
  localeOptions: SelectItem[],
) {
  const preciseMatch = localeOptions.find(
    (option) => option.value === currentUiLocale,
  );
  if (preciseMatch) {
    return preciseMatch.value;
  }

  const partialLocale = currentUiLocale.split('-')[0];
  const partialMatch = localeOptions.find(
    (option) => option.value.split('-')[0] === partialLocale,
  );

  return partialMatch?.value ?? 'default';
}

export const RulesSection: FC<RulesSectionProps> = ({ isLoading = false }) => {
  const intl = useIntl();
  const localeOptions = useAppSelector((state) =>
    localeOptionsSelector(state, intl),
  );
  const [selectedLocale, setSelectedLocale] = useState(() =>
    getDefaultSelectedLocale(intl.locale, localeOptions),
  );
  const rules = useAppSelector((state) => rulesSelector(state, selectedLocale));

  const handleLocaleChange: ChangeEventHandler<HTMLSelectElement> = useCallback(
    (e) => {
      setSelectedLocale(e.currentTarget.value);
    },
    [],
  );

  if (isLoading) {
    return <Section title={intl.formatMessage(messages.rules)} />;
  }

  if (rules.length === 0) {
    return (
      <Section title={intl.formatMessage(messages.rules)}>
        <p>
          <FormattedMessage
            id='about.not_available'
            defaultMessage='This information has not been made available on this server.'
          />
        </p>
      </Section>
    );
  }

  return (
    <Section title={intl.formatMessage(messages.rules)}>
      <ol className='rules-list'>
        {rules.map((rule) => (
          <li key={rule.id}>
            <div className='rules-list__text'>{rule.text}</div>
            {!!rule.hint && <div className='rules-list__hint'>{rule.hint}</div>}
          </li>
        ))}
      </ol>

      {localeOptions.length > 1 && (
        <div className='rules-languages'>
          <label htmlFor='language-select'>
            <FormattedMessage
              id='about.language_label'
              defaultMessage='Language'
            />
          </label>
          <Select onChange={handleLocaleChange} id='language-select'>
            {localeOptions.map((option) => (
              <option
                key={option.value}
                value={option.value}
                selected={option.value === selectedLocale}
              >
                {option.text}
              </option>
            ))}
          </Select>
        </div>
      )}
    </Section>
  );
};

const selectRules = (state: RootState) => {
  const rules = state.server.getIn([
    'server',
    'rules',
  ]) as ImmutableList<Rule> | null;
  if (!rules) {
    return [];
  }
  return rules.toJS() as Rule[];
};

const rulesSelector = createSelector(
  [selectRules, (_state, locale: string) => locale],
  (rules, locale): Rule[] => {
    return rules.map((rule) => {
      const translations = rule.translations;

      // Handle cached responses from earlier versions
      if (!translations) {
        return rule;
      }

      const partialLocale = locale.split('-')[0];
      if (partialLocale && translations[partialLocale]) {
        rule.text = translations[partialLocale].text;
        rule.hint = translations[partialLocale].hint;
      }

      if (translations[locale]) {
        rule.text = translations[locale].text;
        rule.hint = translations[locale].hint;
      }

      return rule;
    });
  },
);

const localeOptionsSelector = createSelector(
  [selectRules, (_state, intl: IntlShape) => intl],
  (rules, intl): SelectItem[] => {
    const langs: Record<string, SelectItem> = {
      default: {
        value: 'default',
        text: intl.formatMessage(messages.defaultLocale),
      },
    };
    // Use the default locale as a target to translate language names.
    const intlLocale =
      // Intl.DisplayNames can be undefined in old browsers
      // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
      Intl.DisplayNames &&
      (new Intl.DisplayNames(intl.locale, {
        type: 'language',
      }) as Intl.DisplayNames | undefined);
    for (const { translations } of rules) {
      for (const locale in translations) {
        if (langs[locale]) {
          continue; // Skip if already added
        }
        langs[locale] = {
          value: locale,
          text: intlLocale?.of(locale) ?? locale,
        };
      }
    }
    return Object.values(langs);
  },
);
