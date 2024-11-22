import { useCallback } from 'react';

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
  className?: string;
}> = ({ content, mentions, language, className }) => {
  const history = useHistory();

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
      className={className}
      ref={handleContentRef}
      lang={language}
      dangerouslySetInnerHTML={{ __html: content }}
    />
  );
};
