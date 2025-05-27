import { useCallback, useMemo, useState } from 'react';
import type { ChangeEventHandler, FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { createSelector } from '@reduxjs/toolkit';
import type { List as ImmutableList } from 'immutable';

import type { SelectItem } from '@/mastodon/components/dropdown_selector';
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
  translations: Record<string, BaseRule>;
}

const rulesSelector = createSelector(
  [
    (state: RootState) =>
      state.server.getIn(['server', 'rules']) as ImmutableList<Rule> | null,
  ],
  (rules) => (rules?.toJS() ?? []) as Rule[],
);

export const RulesSection: FC<RulesSectionProps> = ({ isLoading = false }) => {
  const intl = useIntl();
  const rules = useAppSelector(rulesSelector);
  const [locale, setLocale] = useState(intl.locale);
  const localeOptions: SelectItem[] = useMemo(() => {
    const langs: Record<string, SelectItem> = {
      default: {
        value: 'default',
        text: intl.formatMessage(messages.defaultLocale),
      },
    };
    // Use the default locale as a target to translate language names.
    const intlLocale = new Intl.DisplayNames(intl.locale, {
      type: 'language',
    });
    for (const { translations } of rules) {
      for (const locale in translations) {
        if (langs[locale]) {
          continue; // Skip if already added
        }
        langs[locale] = {
          value: locale,
          text: intlLocale.of(locale) ?? locale,
        };
      }
    }
    return Object.values(langs);
  }, [intl, rules]);
  const handleLocaleChange: ChangeEventHandler<HTMLSelectElement> = useCallback(
    (e) => {
      setLocale(e.currentTarget.value);
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
        {rules.map((rule) => {
          const firstLocale = locale.split('-')[0] ?? '';
          /* eslint-disable @typescript-eslint/prefer-nullish-coalescing -- Safer to use conditionals. */
          const text =
            rule.translations[locale]?.text ||
            rule.translations[firstLocale]?.text ||
            rule.text;
          const hint =
            rule.translations[locale]?.hint ||
            rule.translations[firstLocale]?.hint ||
            rule.hint;
          /* eslint-enable */
          return (
            <li key={rule.id}>
              <div className='rules-list__text'>{text}</div>
              {!!hint && <div className='rules-list__hint'>{hint}</div>}
            </li>
          );
        })}
      </ol>

      <div className='rules-languages'>
        <label htmlFor='language-select'>
          <FormattedMessage
            id='about.language_label'
            defaultMessage='Language'
          />
        </label>
        <select onChange={handleLocaleChange} id='language-select'>
          {localeOptions.map((option) => (
            <option
              key={option.value}
              value={option.value}
              selected={option.value === locale}
            >
              {option.text}
            </option>
          ))}
        </select>
      </div>
    </Section>
  );
};
