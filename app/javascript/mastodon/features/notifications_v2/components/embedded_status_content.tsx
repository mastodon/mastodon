import { useCallback, useRef } from 'react';

import { useHistory } from 'react-router-dom';

import type { List } from 'immutable';

import type { History } from 'history';

import type { Mention } from './embedded_status';

const handleMentionClick = (
  history: History,
  mention: Mention,
  e: MouseEvent,
) => {
  if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
    e.preventDefault();
    history.push(`/@${mention.get('acct')}`);
  }
};

const handleHashtagClick = (
  history: History,
  hashtag: string,
  e: MouseEvent,
) => {
  if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
    e.preventDefault();
    history.push(`/tags/${hashtag.replace(/^#/, '')}`);
  }
};

export const EmbeddedStatusContent: React.FC<{
  content: string;
  mentions: List<Mention>;
  language: string;
  onClick?: () => void;
  className?: string;
}> = ({ content, mentions, language, onClick, className }) => {
  const clickCoordinatesRef = useRef<[number, number] | null>();
  const history = useHistory();

  const handleMouseDown = useCallback<React.MouseEventHandler<HTMLDivElement>>(
    ({ clientX, clientY }) => {
      clickCoordinatesRef.current = [clientX, clientY];
    },
    [clickCoordinatesRef],
  );

  const handleMouseUp = useCallback<React.MouseEventHandler<HTMLDivElement>>(
    ({ clientX, clientY, target, button }) => {
      const [startX, startY] = clickCoordinatesRef.current ?? [0, 0];
      const [deltaX, deltaY] = [
        Math.abs(clientX - startX),
        Math.abs(clientY - startY),
      ];

      let element: HTMLDivElement | null = target as HTMLDivElement;

      while (element) {
        if (
          element.localName === 'button' ||
          element.localName === 'a' ||
          element.localName === 'label'
        ) {
          return;
        }

        element = element.parentNode as HTMLDivElement | null;
      }

      if (deltaX + deltaY < 5 && button === 0 && onClick) {
        onClick();
      }

      clickCoordinatesRef.current = null;
    },
    [clickCoordinatesRef, onClick],
  );

  const handleMouseEnter = useCallback<React.MouseEventHandler<HTMLDivElement>>(
    ({ currentTarget }) => {
      const emojis =
        currentTarget.querySelectorAll<HTMLImageElement>('.custom-emoji');

      for (const emoji of emojis) {
        const newSrc = emoji.getAttribute('data-original');
        if (newSrc) emoji.src = newSrc;
      }
    },
    [],
  );

  const handleMouseLeave = useCallback<React.MouseEventHandler<HTMLDivElement>>(
    ({ currentTarget }) => {
      const emojis =
        currentTarget.querySelectorAll<HTMLImageElement>('.custom-emoji');

      for (const emoji of emojis) {
        const newSrc = emoji.getAttribute('data-static');
        if (newSrc) emoji.src = newSrc;
      }
    },
    [],
  );

  const handleContentRef = useCallback(
    (node: HTMLDivElement | null) => {
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
          link.addEventListener(
            'click',
            handleMentionClick.bind(null, history, mention),
            false,
          );
          link.setAttribute('title', `@${mention.get('acct')}`);
          link.setAttribute('href', `/@${mention.get('acct')}`);
        } else if (
          link.textContent?.[0] === '#' ||
          link.previousSibling?.textContent?.endsWith('#')
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
    },
    [mentions, history],
  );

  return (
    <div
      role='button'
      tabIndex={0}
      className={className}
      ref={handleContentRef}
      lang={language}
      dangerouslySetInnerHTML={{ __html: content }}
      onMouseDown={handleMouseDown}
      onMouseUp={handleMouseUp}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    />
  );
};
