import { useCallback, useRef } from 'react';
import { useHistory } from 'react-router-dom';

const handleMentionClick = (history: unknown, mention: unknown, e: Event) => {
  if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
    e.preventDefault();
    history.push(`/@${mention.get('acct')}`);
  }
};

const handleHashtagClick = (history: unknown, hashtag: string, e: Event) => {
  if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
    e.preventDefault();
    history.push(`/tags/${hashtag.replace(/^#/, '')}`);
  }
};

export const EmbeddedStatusContent: React.FC<{
  content: string;
  mentions: unknown;
  language: string;
  onClick?: unknown;
  className?: string;
}> = ({ content, mentions, language, onClick, className }) => {
  const clickCoordinatesRef = useRef();
  const history = useHistory();

  const handleMouseDown = useCallback(
    ({ clientX, clientY }) => {
      clickCoordinatesRef.current = [clientX, clientY];
    },
    [clickCoordinatesRef],
  );

  const handleMouseUp = useCallback(
    ({ clientX, clientY, target, button }) => {
      const [startX, startY] = clickCoordinatesRef.current ?? [0, 0];
      const [deltaX, deltaY] = [
        Math.abs(clientX - startX),
        Math.abs(clientY - startY),
      ];

      let element = target;

      while (element) {
        if (
          element.localName === 'button' ||
          element.localName === 'a' ||
          element.localName === 'label'
        ) {
          return;
        }

        element = element.parentNode;
      }

      if (deltaX + deltaY < 5 && button === 0 && onClick) {
        onClick();
      }

      clickCoordinatesRef.current = null;
    },
    [clickCoordinatesRef, onClick],
  );

  const handleMouseEnter = useCallback(({ currentTarget }) => {
    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (const emoji of emojis) {
      emoji.src = emoji.getAttribute('data-original');
    }
  }, []);

  const handleMouseLeave = useCallback(({ currentTarget }) => {
    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (const emoji of emojis) {
      emoji.src = emoji.getAttribute('data-static');
    }
  }, []);

  const handleContentRef = useCallback(
    (node) => {
      if (!node) {
        return;
      }

      const links = node.querySelectorAll('a');

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
          link.textContent[0] === '#' ||
          (link.previousSibling &&
            link.previousSibling.textContent &&
            link.previousSibling.textContent[
              link.previousSibling.textContent.length - 1
            ] === '#')
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
      tabIndex='0'
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
