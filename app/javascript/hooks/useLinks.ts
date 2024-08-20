import { useCallback } from 'react';

import { useHistory } from 'react-router-dom';

import { openURL } from 'mastodon/actions/search';
import { useAppDispatch } from 'mastodon/store';

const isMentionClick = (element: HTMLAnchorElement) =>
  element.classList.contains('mention');

const isHashtagClick = (element: HTMLAnchorElement) =>
  element.textContent?.[0] === '#' ||
  element.previousSibling?.textContent?.endsWith('#');

export const useLinks = () => {
  const history = useHistory();
  const dispatch = useAppDispatch();

  const handleHashtagClick = useCallback(
    (element: HTMLAnchorElement) => {
      const { textContent } = element;

      if (!textContent) return;

      history.push(`/tags/${textContent.replace(/^#/, '')}`);
    },
    [history],
  );

  const handleMentionClick = useCallback(
    (element: HTMLAnchorElement) => {
      dispatch(
        openURL(element.href, history, () => {
          window.location.href = element.href;
        }),
      );
    },
    [dispatch, history],
  );

  const handleClick = useCallback(
    (e: React.MouseEvent) => {
      const target = (e.target as HTMLElement).closest('a');

      if (!target || e.button !== 0 || e.ctrlKey || e.metaKey) {
        return;
      }

      if (isMentionClick(target)) {
        e.preventDefault();
        handleMentionClick(target);
      } else if (isHashtagClick(target)) {
        e.preventDefault();
        handleHashtagClick(target);
      }
    },
    [handleMentionClick, handleHashtagClick],
  );

  return handleClick;
};
