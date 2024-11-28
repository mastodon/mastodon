import classNames from 'classnames';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import { useLinks } from 'mastodon/../hooks/useLinks';
import { Icon } from 'mastodon/components/icon';
import type { Account } from 'mastodon/models/account';

export const AccountFields: React.FC<{
  fields: Account['fields'];
  limit: number;
}> = ({ fields, limit = -1 }) => {
  const handleClick = useLinks();

  if (fields.size === 0) {
    return null;
  }

  return (
    <div className='account-fields' onClickCapture={handleClick}>
      {fields.take(limit).map((pair, i) => (
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
