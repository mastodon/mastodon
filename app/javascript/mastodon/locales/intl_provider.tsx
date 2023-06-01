import { useEffect, useState } from 'react';

import { IntlProvider as BaseIntlProvider } from 'react-intl';

import { loadLocale } from 'mastodon/load_locale';

import { getLocale, isLocaleLoaded, onProviderError } from './index';

export const IntlProvider: React.FC<
  Omit<React.ComponentProps<typeof BaseIntlProvider>, 'locale' | 'messages'>
> = ({ children, ...props }) => {
  const [localeLoaded, setLocaleLoaded] = useState(false);

  useEffect(() => {
    async function loadLocaleData() {
      if (!isLocaleLoaded()) {
        await loadLocale();
      }

      setLocaleLoaded(true);
    }
    void loadLocaleData();
  }, []);

  if (!localeLoaded) return null;

  const { locale, messages } = getLocale();

  return (
    <BaseIntlProvider
      locale={locale}
      messages={messages}
      onError={onProviderError}
      {...props}
    >
      {children}
    </BaseIntlProvider>
  );
};
