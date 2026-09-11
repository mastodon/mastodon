import { FormattedMessage, useIntl } from 'react-intl';

import { TranslateIcon } from '@phosphor-icons/react';

import { useIdentity } from '@/mastodon/identity_context';
import { languages as preloadedLanguages } from '@/mastodon/initial_state';
import type { AnyStatusShape } from '@/mastodon/models/status';
import { useAppSelector } from '@/mastodon/store';

import { Button } from '../button/redesign';

import classes from './styles.module.scss';

export const TranslateButton: React.FC<{
  status: AnyStatusShape;
  onTranslate: React.MouseEventHandler<HTMLButtonElement>;
}> = ({ status, onTranslate }) => {
  const { signedIn } = useIdentity();
  const targetLanguages = useAppSelector(
    (state) => state.server.translationLanguages.item?.[status.language],
  );
  const intl = useIntl();

  const { translation } = status;

  if (
    !signedIn ||
    !['public', 'unlisted'].includes(status.visibility) ||
    status.search_index?.trim().length === 0 ||
    !targetLanguages?.includes(intl.locale.replace(/[_-].*/, ''))
  ) {
    return null;
  }

  if (!translation || translation.isLoading) {
    return (
      <div className={classes.translate}>
        <Button
          size='sm'
          color='accent'
          variant='ghost'
          onClick={onTranslate}
          leadingIcon={TranslateIcon}
          className={classes.buttonAlign}
          loading={translation?.isLoading}
        >
          <FormattedMessage id='status.translate' defaultMessage='Translate' />
        </Button>
      </div>
    );
  }

  const language = preloadedLanguages?.find(
    (lang) => lang[0] === translation.detected_source_language,
  );
  const languageName = language
    ? language[1]
    : translation.detected_source_language;
  const provider = translation.provider;

  return (
    <div className={classes.translate}>
      <Button
        size='sm'
        color='accent'
        variant='ghost'
        onClick={onTranslate}
        leadingIcon={TranslateIcon}
        className={classes.buttonAlign}
      >
        <FormattedMessage
          id='status.show_original'
          defaultMessage='Show original'
        />
      </Button>

      <div className={classes.translateInfo}>
        <FormattedMessage
          id='status.translated_from_with'
          defaultMessage='Translated from {lang} using {provider}'
          values={{ lang: languageName, provider }}
        />
      </div>
    </div>
  );
};
