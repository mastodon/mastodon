import type React from 'react';
import { useCallback } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classnames from 'classnames';

import { toggleStatusCollapse } from '@/mastodon/actions/statuses';
import { useIdentity } from '@/mastodon/identity_context';
import { languages as preloadedLanguages } from '@/mastodon/initial_state';
import type { StatusTranslation } from '@/mastodon/models/status';
import { selectPlainStatus } from '@/mastodon/selectors/statuses';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';

import { EmojiHTML } from '../emoji/html';
import { Icon } from '../icon';
import { Poll } from '../poll';

import { useElementHandledLink } from './handled_link';

const MAX_HEIGHT = 706; // 22px * 32 (+ 2px padding at the top)

export const StatusContent: React.FC<{
  statusId: string;
  onClick?: React.MouseEventHandler;
  onTranslate?: React.MouseEventHandler<HTMLButtonElement>;
  collapsible?: boolean;
}> = ({ statusId, onClick, onTranslate, collapsible }) => {
  const status = useAppSelector((state) => selectPlainStatus(state, statusId));
  const { signedIn } = useIdentity();
  const targetLanguages = useAppSelector(
    (state) =>
      state.server.translationLanguages.item?.[status?.language ?? 'und'],
  );
  const intl = useIntl();

  // Determines if a long post should show the read more button.
  const dispatch = useAppDispatch();
  const handleCollapse = useCallback(
    (node: HTMLDivElement | null) => {
      if (!node || status?.collapsed !== null || !collapsible) {
        return;
      }

      const text = node.querySelector(':scope > .status__content__text');

      const collapsed =
        (node.clientHeight > MAX_HEIGHT ||
          (text !== null && text.scrollWidth > text.clientWidth)) &&
        !status.spoiler_text;

      dispatch(toggleStatusCollapse(status.id, collapsed));
    },
    [collapsible, status, dispatch],
  );

  // Trigger the click event if clicking outside a link, button, or label inside a status.
  const handleClick: React.MouseEventHandler<HTMLDivElement> = useCallback(
    (event) => {
      const { target } = event;
      if (
        !onClick ||
        !(target instanceof Element) ||
        target.closest(':is(a, button, label)')
      ) {
        return;
      }
      onClick(event);
    },
    [onClick],
  );

  const hrefToMention = useCallback(
    (href: string) => status?.mentions.find((item) => item.url === href),
    [status?.mentions],
  );
  const hrefToCollectionId = useCallback(
    (href: string) =>
      status?.tagged_collections.find((item) => item.url === href)?.id,
    [status?.tagged_collections],
  );
  const htmlHandlers = useElementHandledLink({
    hashtagAccountId: status?.account,
    hrefToCollectionId,
    hrefToMention,
  });

  if (!status) {
    return null;
  }

  const language = status.translation?.language ?? status.language;

  const renderReadMore = !!onClick && status.collapsed;
  const readMoreButton = renderReadMore && (
    <button
      className='status__content__read-more-button'
      type='button'
      onClick={onClick}
      key='read-more'
    >
      <FormattedMessage id='status.read_more' defaultMessage='Read more' />
      <Icon id='angle-right' icon={ChevronRightIcon} />
    </button>
  );

  const renderTranslate =
    !!onTranslate &&
    signedIn &&
    ['public', 'unlisted'].includes(status.visibility) &&
    status.search_index &&
    status.search_index.trim().length > 0 &&
    targetLanguages?.includes(intl.locale.replace(/[_-].*/, ''));
  const translateButton = renderTranslate && (
    <TranslateButton onClick={onTranslate} translation={status.translation} />
  );

  const poll = !!status.poll && (
    <Poll
      pollId={status.poll}
      statusUrl={status.uri}
      accountId={status.account}
      lang={language}
    />
  );

  const content = (
    <EmojiHTML
      className='status__content__text status__content__text--visible translate'
      lang={language}
      htmlString={status.translation?.contentHtml ?? status.contentHtml}
      extraEmojis={status.emojis}
      {...htmlHandlers}
    />
  );

  const classNames = classnames('status__content', {
    'status__content--with-action': onClick,
    'status__content--collapsed': renderReadMore,
  });

  if (!onClick) {
    return (
      <div className={classNames} ref={handleCollapse}>
        {content}
        {poll}
        {translateButton}
      </div>
    );
  }

  /* eslint-disable jsx-a11y/no-static-element-interactions, jsx-a11y/click-events-have-key-events */
  return (
    <>
      <div className={classNames} ref={handleCollapse} onClick={handleClick}>
        {content}
        {poll}
        {translateButton}
      </div>

      {readMoreButton}
    </>
  );
  /* eslint-enable jsx-a11y/no-static-element-interactions, jsx-a11y/click-events-have-key-events */
};

const TranslateButton: React.FC<{
  onClick: React.MouseEventHandler<HTMLButtonElement>;
  translation?: StatusTranslation;
}> = ({ translation, onClick }) => {
  if (!translation) {
    return (
      <button
        type='button'
        className='status__content__translate-button'
        onClick={onClick}
      >
        <FormattedMessage id='status.translate' defaultMessage='Translate' />
      </button>
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
      <button type='button' className='link-button' onClick={onClick}>
        <FormattedMessage
          id='status.show_original'
          defaultMessage='Show original'
        />
      </button>

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
