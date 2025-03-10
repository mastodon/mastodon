import { useCallback } from 'react';

import { useHistory } from 'react-router-dom';

import { isFulfilled, isRejected } from '@reduxjs/toolkit';

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
    async (element: HTMLAnchorElement) => {
      const result = await dispatch(openURL({ url: element.href }));

      if (isFulfilled(result)) {
        if (result.payload.accounts[0]) {
          history.push(`/@${result.payload.accounts[0].acct}`);
        } else if (result.payload.statuses[0]) {
          history.push(
            `/@${result.payload.statuses[0].account.acct}/${result.payload.statuses[0].id}`,
          );
        } else {
          window.location.href = element.href;
        }
      } else if (isRejected(result)) {
        window.location.href = element.href;
      }
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
        void handleMentionClick(target);
      } else if (isHashtagClick(target)) {
        e.preventDefault();
        handleHashtagClick(target);
      }
    },
    [handleMentionClick, handleHashtagClick],
  );

  return handleClick;
};
