import type React from 'react';
import { useCallback, useState } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { CaretRightIcon } from '@phosphor-icons/react';

import { useIdentity } from '@/mastodon/identity_context';
import { languages as preloadedLanguages } from '@/mastodon/initial_state';
import type {
  ExpandedStatusShape,
  StatusShape,
  StatusTranslation,
} from '@/mastodon/models/status';
import { useAppSelector } from '@/mastodon/store';

import { Button } from '../button/redesign';
import { EmojiHTML } from '../emoji/html';

import { useHandlersForStatus } from './hooks';
import classes from './styles.module.scss';

const MAX_HEIGHT = 706; // 22px * 32 (+ 2px padding at the top)

export const StatusContent: React.FC<
  {
    status: StatusShape | ExpandedStatusShape;
    statusContent?: string;
    onTranslate?: () => void;
    onReadMore?: () => void;
    collapsible?: boolean;
  } & React.ComponentPropsWithRef<'div'>
> = ({
  status,
  statusContent,
  onTranslate,
  onReadMore,
  collapsible,
  children,
  className,
  ...props
}) => {
  const { signedIn } = useIdentity();
  const targetLanguages = useAppSelector(
    (state) => state.server.translationLanguages.item?.[status.language],
  );
  const intl = useIntl();

  // Determines if a long post should show the read more button.
  const [collapsed, setCollapsed] = useState(false);
  const onRef = useCallback(
    (node: HTMLDivElement | null) => {
      if (!node || collapsed) {
        return;
      }

      setCollapsed(
        (node.clientHeight > MAX_HEIGHT ||
          node.scrollWidth > node.clientWidth) &&
          !status.spoiler_text,
      );
    },
    [collapsed, status.spoiler_text],
  );

  const htmlHandlers = useHandlersForStatus(status);

  const language = status.translation?.language ?? status.language;

  const renderTranslate = !!(
    onTranslate &&
    signedIn &&
    ['public', 'unlisted'].includes(status.visibility) &&
    status.search_index?.trim().length &&
    targetLanguages?.includes(intl.locale.replace(/[_-].*/, ''))
  );
  const isCollapsed = !!onReadMore && collapsible && collapsed;

  return (
    <EmojiHTML
      {...props}
      className={classNames(
        className,
        classes.content,
        isCollapsed && classes.collapsed,
      )}
      ref={onRef}
      lang={language}
      htmlString={
        statusContent ?? status.translation?.contentHtml ?? status.contentHtml
      }
      extraEmojis={status.emojis}
      {...htmlHandlers}
    >
      {children}

      {renderTranslate && (
        <TranslateButton
          translation={status.translation}
          onTranslate={onTranslate}
        />
      )}

      {isCollapsed && (
        <Button
          size='sm'
          variant='ghost'
          onClick={onReadMore}
          trailingIcon={CaretRightIcon}
          className={classNames(classes.contentReadMore)}
        >
          <FormattedMessage id='status.read_more' defaultMessage='Read more' />
        </Button>
      )}
    </EmojiHTML>
  );
};

const TranslateButton: React.FC<{
  onTranslate: React.MouseEventHandler<HTMLButtonElement>;
  translation?: StatusTranslation;
}> = ({ translation, onTranslate }) => {
  if (!translation) {
    return (
      <Button
        size='sm'
        variant='ghost'
        onClick={onTranslate}
        className={classes.buttonAlign}
      >
        <FormattedMessage id='status.translate' defaultMessage='Translate' />
      </Button>
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
    <div className='translate-button'>
      <Button size='sm' variant='ghost' onClick={onTranslate}>
        <FormattedMessage
          id='status.show_original'
          defaultMessage='Show original'
        />
      </Button>

      <div className='translate-button__meta'>
        <FormattedMessage
          id='status.translated_from_with'
          defaultMessage='Translated from {lang} using {provider}'
          values={{ lang: languageName, provider }}
        />
      </div>
    </div>
  );
};
