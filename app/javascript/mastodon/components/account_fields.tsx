import { useEffect, useRef, useCallback } from 'react';

import classNames from 'classnames';
import { useHistory } from 'react-router-dom';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import { openURL } from 'mastodon/actions/search';
import { Icon } from 'mastodon/components/icon';
import type { Account } from 'mastodon/models/account';
import { useAppDispatch } from 'mastodon/store';

export const AccountFields: React.FC<{
  fields: Account['fields'];
}> = ({ fields }) => {
  const ref = useRef<HTMLDivElement>(null);
  const history = useHistory();
  const dispatch = useAppDispatch();

  const handleHashtagClick = useCallback(
    (e: MouseEvent) => {
      const { currentTarget } = e;
      if (!(currentTarget instanceof HTMLElement)) return;

      if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
        const { textContent } = currentTarget;
        if (!textContent) return;

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
    if (!ref.current) {
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
  }, [fields, handleHashtagClick, handleMentionClick]);

  if (fields.size === 0) {
    return null;
  }

  return (
    <div className='account-fields' ref={ref}>
      {fields.map((pair, i) => (
        <dl
          key={i}
          className={classNames({ verified: pair.get('verified_at') })}
        >
          <dt
            dangerouslySetInnerHTML={{ __html: pair.get('name_emojified') }}
            className='translate'
          />

          <dd className='translate' title={pair.get('value_plain') ?? ''}>
            {pair.get('verified_at') && (
              <Icon id='check' icon={CheckIcon} className='verified__mark' />
            )}
            <span
              dangerouslySetInnerHTML={{ __html: pair.get('value_emojified') }}
            />
          </dd>
        </dl>
      ))}
    </div>
  );
};
