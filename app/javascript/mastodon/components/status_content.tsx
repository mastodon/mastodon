import { useCallback, useRef, useLayoutEffect } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classnames from 'classnames';
import { useHistory } from 'react-router-dom';

import type { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import type { History } from 'history';

import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import { Icon } from 'mastodon/components/icon';
import PollContainer from 'mastodon/containers/poll_container';
import { useIdentity } from 'mastodon/identity_context';
import {
  autoPlayGif,
  languages as preloadedLanguages,
} from 'mastodon/initial_state';
import type { Status, Translation } from 'mastodon/models/status';
import { useAppSelector } from 'mastodon/store';



const MAX_HEIGHT = 706; // 22px * 32 (+ 2px padding at the top)

export const getStatusContent = (status: Status): string =>
  status.getIn(['translation', 'contentHtml']) || status.get('contentHtml');

const TranslateButton: React.FC<{
  translation: ImmutableList<Translation>;
  onClick: () => void;
}> = ({ translation, onClick }) => {
  if (translation) {
    const language = preloadedLanguages?.find(
      (lang) => lang[0] === translation.get('detected_source_language'),
    );
    const languageName = language
      ? language[2]
      : translation.get('detected_source_language');
    const provider = translation.get('provider');

    return (
      <div className='translate-button'>
        <div className='translate-button__meta'>
          <FormattedMessage
            id='status.translated_from_with'
            defaultMessage='Translated from {lang} using {provider}'
            values={{ lang: languageName, provider }}
          />
        </div>

        <button className='link-button' onClick={onClick}>
          <FormattedMessage
            id='status.show_original'
            defaultMessage='Show original'
          />
        </button>
      </div>
    );
  }

  return (
    <button className='status__content__translate-button' onClick={onClick}>
      <FormattedMessage id='status.translate' defaultMessage='Translate' />
    </button>
  );
};

const handleMentionClick = (
  history: History,
  mention: string,
  e: MouseEvent,
) => {
  if (history && e.button === 0 && !(e.ctrlKey || e.metaKey)) {
    e.preventDefault();
    history.push(`/@${mention}`);
  }
};

const handleHashtagClick = (
  history: History,
  hashtag: string,
  e: MouseEvent,
) => {
  hashtag = hashtag.replace(/^#/, '');

  if (history && e.button === 0 && !(e.ctrlKey || e.metaKey)) {
    e.preventDefault();
    history.push(`/tags/${hashtag}`);
  }
};

type ClickCoordinates = [number, number];

export const StatusContent: React.FC<{
  status: Status;
  statusContent: string;
  onTranslate?: () => void;
  onClick?: (arg0?: React.MouseEvent | MouseEvent) => void;
  onCollapsedToggle?: (arg0: boolean) => void;
  collapsible?: boolean;
}> = ({
  status,
  statusContent,
  onTranslate,
  onClick,
  collapsible,
  onCollapsedToggle,
}) => {
  const { signedIn } = useIdentity();
  const history = useHistory();
  const intl = useIntl();
  const languages = useAppSelector(
    (state) =>
      state.server.getIn(['translationLanguages', 'items']) as ImmutableMap<
        string,
        ImmutableList<string>
      >,
  );
  const clickCoordinates = useRef<ClickCoordinates | null>(null);
  const nodeRef = useRef<HTMLDivElement | null>(null);

  const handleMouseEnter = useCallback(
    ({ currentTarget }: React.MouseEvent) => {
      if (autoPlayGif) {
        return;
      }

      const emojis =
        currentTarget.querySelectorAll<HTMLImageElement>('.custom-emoji');

      for (const emoji of emojis) {
        const originalUrl = emoji.getAttribute('data-original');

        if (originalUrl) {
          emoji.src = originalUrl;
        }
      }
    },
    [],
  );

  const handleMouseLeave = useCallback(
    ({ currentTarget }: React.MouseEvent) => {
      if (autoPlayGif) {
        return;
      }

      const emojis =
        currentTarget.querySelectorAll<HTMLImageElement>('.custom-emoji');

      for (const emoji of emojis) {
        const staticUrl = emoji.getAttribute('data-static');

        if (staticUrl) {
          emoji.src = staticUrl;
        }
      }
    },
    [],
  );

  const handleMouseDown = useCallback((e: React.MouseEvent) => {
    clickCoordinates.current = [e.clientX, e.clientY];
  }, []);

  const handleMouseUp = useCallback(
    (e: React.MouseEvent) => {
      if (!clickCoordinates.current) {
        return;
      }

      const [startX, startY] = clickCoordinates.current;
      const [deltaX, deltaY] = [
        Math.abs(e.clientX - startX),
        Math.abs(e.clientY - startY),
      ];

      if (!(e.target instanceof HTMLElement)) {
        return;
      }

      let element: HTMLElement | null = e.target;

      while (element) {
        if (
          element.localName === 'button' ||
          element.localName === 'a' ||
          element.localName === 'label'
        ) {
          return;
        }

        if (!(element.parentNode instanceof HTMLElement)) {
          break;
        }

        element = element.parentNode;
      }

      if (
        deltaX + deltaY < 5 &&
        (e.button === 0 || e.button === 1) &&
        e.detail >= 1 &&
        onClick
      ) {
        onClick(e);
      }

      clickCoordinates.current = null;
    },
    [onClick],
  );

  const handleTranslate = useCallback(() => {
    onTranslate?.();
  }, [onTranslate]);

  const mentions = status.get('mentions') as ImmutableList<ImmutableMap<string, string>>;
  const spoilerText = status.get('spoiler_text') as string;
  const visibility = status.get('visibility') as string;
  const searchIndex = status.get('search_index') as string;
  const collapsed = status.get('collapsed') as boolean | undefined;

  useLayoutEffect(() => {
    const node = nodeRef.current;

    if (!node) {
      return;
    }

    const links = node.querySelectorAll<HTMLAnchorElement>('a');

    for (const link of links) {
      if (link.classList.contains('status-link')) {
        continue;
      }

      link.classList.add('status-link');

      const mention = mentions.find((item) => link.href === item.get('url'));

      if (mention) {
        const acct = mention.get('acct')!;
        const id = mention.get('id')!;

        link.addEventListener(
          'click',
          handleMentionClick.bind(null, history, acct),
          false,
        );
        link.setAttribute('title', `@${acct}`);
        link.setAttribute('href', `/@${acct}`);
        link.setAttribute('data-hover-card-account', id);
      } else if (
        link.textContent?.[0] === '#' ||
        (link.previousSibling?.textContent?.endsWith('#'))
      ) {
        link.addEventListener(
          'click',
          handleHashtagClick.bind(null, history, link.text),
          false,
        );
        link.setAttribute('href', `/tags/${link.text.replace(/^#/, '')}`);
      } else {
        link.setAttribute('title', link.href);
        link.classList.add('unhandled-link');
      }
    }

    if (collapsed && onCollapsedToggle) {
      const collapsed =
        !!collapsible &&
        !!onClick &&
        node.clientHeight > MAX_HEIGHT &&
        spoilerText.length === 0;

      onCollapsedToggle(collapsed);
    }
  }, [history, mentions, spoilerText, onCollapsedToggle, collapsible, onClick]);

  const renderReadMore = onClick && status.get('collapsed');
  const contentLocale = intl.locale.replace(/[_-].*/, '');
  const originalLanguage = (status.get('language') as string) || 'und';
  const targetLanguages = languages.get(originalLanguage);
  const renderTranslate =
    onTranslate &&
    signedIn &&
    ['public', 'unlisted'].includes(visibility) &&
    searchIndex.trim().length > 0 &&
    targetLanguages?.includes(contentLocale);

  const content = { __html: statusContent ?? getStatusContent(status) };
  const language =
    (status.getIn(['translation', 'language']) as string) ?? originalLanguage;
  const classNames = classnames('status__content', {
    'status__content--with-action': onClick && history,
    'status__content--collapsed': renderReadMore,
  });

  const readMoreButton = renderReadMore && (
    <button
      className='status__content__read-more-button'
      onClick={onClick}
      key='read-more'
    >
      <FormattedMessage id='status.read_more' defaultMessage='Read more' />
      <Icon id='angle-right' icon={ChevronRightIcon} />
    </button>
  );

  const translateButton = renderTranslate && (
    <TranslateButton
      onClick={handleTranslate}
      translation={status.get('translation')}
    />
  );

  const poll = !!status.get('poll') && (
    <PollContainer
      pollId={status.get('poll')}
      status={status}
      lang={language}
    />
  );

  if (onClick) {
    return (
      <>
        <div
          className={classNames}
          ref={nodeRef}
          onMouseDown={handleMouseDown}
          onMouseUp={handleMouseUp}
          key='status-content'
          onMouseEnter={handleMouseEnter}
          onMouseLeave={handleMouseLeave}
        >
          <div
            className='status__content__text status__content__text--visible translate'
            lang={language}
            dangerouslySetInnerHTML={content}
          />

          {poll}
          {translateButton}
        </div>

        {readMoreButton}
      </>
    );
  } else {
    return (
      <div
        className={classNames}
        ref={nodeRef}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
      >
        <div
          className='status__content__text status__content__text--visible translate'
          lang={language}
          dangerouslySetInnerHTML={content}
        />

        {poll}
        {translateButton}
      </div>
    );
  }
};
