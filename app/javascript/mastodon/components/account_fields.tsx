
import { useEffect, useRef, useCallback } from 'react';

import classNames from 'classnames';
import { useHistory } from 'react-router-dom';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import { openURL } from 'mastodon/actions/search';
import type { ApiAccountFieldJSON } from 'mastodon/api_types/accounts';
import { Icon } from 'mastodon/components/icon';
import { useAppDispatch } from 'mastodon/store';

export const AccountFields: React.FC<{
  fields: ApiAccountFieldJSON[];
}> = ({ fields }) => {
  const ref = useRef(null);
  const history = useHistory();
  const dispatch = useAppDispatch();

  const handleHashtagClick = useCallback(
    (e) => {
      if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        history.push(`/tags/${e.currentTarget.textContent.replace(/^#/, '')}`);
      }
    },
    [history],
  );

  const handleMentionClick = useCallback(
    (e) => {
      if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
        e.preventDefault();

        dispatch(
          openURL(e.currentTarget.href, history, () => {
            window.location = e.currentTarget.href;
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

    const links = ref.current.querySelectorAll('a');

    for (const link of links) {
      if (
        link.textContent[0] === '#' ||
        (link.previousSibling?.textContent &&
          link.previousSibling.textContent[
            link.previousSibling.textContent.length - 1
          ] === '#')
      ) {
        link.addEventListener('click', handleHashtagClick, false);
      } else if (link.classList.contains('mention')) {
        link.addEventListener('click', handleMentionClick, false);
      }
    }

    return () => {
      for (const link of links) {
        if (
          link.textContent[0] === '#' ||
          (link.previousSibling?.textContent &&
            link.previousSibling.textContent[
              link.previousSibling.textContent.length - 1
            ] === '#')
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

          <dd className='translate' title={pair.get('value_plain')}>
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
