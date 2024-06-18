import { useEffect, useRef, useCallback } from 'react';

import { useHistory } from 'react-router-dom';

import { openURL } from 'mastodon/actions/search';
import { useAppDispatch } from 'mastodon/store';

export const AccountBio: React.FC<{
  note: string;
  className: string;
}> = ({ note, className }) => {
  const ref = useRef<HTMLDivElement>(null);
  const history = useHistory();
  const dispatch = useAppDispatch();

  const handleHashtagClick = useCallback(
    (e: MouseEvent) => {
      const { currentTarget } = e;
      if (!(currentTarget instanceof HTMLElement)) return;
      const { textContent } = currentTarget;

      if (textContent && e.button === 0 && !(e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        history.push(`/tags/${textContent.replace(/^#/, '')}`);
      }
    },
    [history],
  );

  const handleMentionClick = useCallback(
    (e: MouseEvent) => {
      const { currentTarget } = e;
      if (!(currentTarget instanceof HTMLAnchorElement)) return;

      if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
        e.preventDefault();

        dispatch(
          openURL(currentTarget.href, history, () => {
            window.location.href = currentTarget.href;
          }),
        );
      }
    },
    [dispatch, history],
  );

  useEffect(() => {
    if (ref.current === null) {
      return;
    }

    const links = ref.current.querySelectorAll<HTMLAnchorElement>('a');

    for (const link of links) {
      if (
        link.textContent?.[0] === '#' ||
        link.previousSibling?.textContent?.endsWith('#')
      ) {
        link.addEventListener('click', handleHashtagClick, false);
      } else if (link.classList.contains('mention')) {
        link.addEventListener('click', handleMentionClick, false);
      }
    }

    return () => {
      for (const link of links) {
        if (
          link.textContent?.[0] === '#' ||
          link.previousSibling?.textContent?.endsWith('#')
        ) {
          link.removeEventListener('click', handleHashtagClick);
        } else if (link.classList.contains('mention')) {
          link.removeEventListener('click', handleMentionClick);
        }
      }
    };
  }, [note, handleHashtagClick, handleMentionClick]);

  if (note.length === 0 || note === '<p></p>') {
    return null;
  }

  return (
    <div
      ref={ref}
      className={`${className} translate`}
      dangerouslySetInnerHTML={{ __html: note }}
    />
  );
};
