import classNames from 'classnames';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import { Icon } from 'mastodon/components/icon';
import { useLinks } from 'mastodon/hooks/useLinks';
import type { Account } from 'mastodon/models/account';

import { CustomEmojiProvider } from './emoji/context';
import { EmojiHTML } from './emoji/html';

export const AccountFields: React.FC<{
  fields: Account['fields'];
  extraEmojis: Account['emojis'];
  limit: number;
}> = ({ fields, extraEmojis, limit = -1 }) => {
  const handleClick = useLinks();

  if (fields.size === 0) {
    return null;
  }

  return (
    <div className='account-fields' onClickCapture={handleClick}>
      <CustomEmojiProvider emojis={extraEmojis}>
        {fields.take(limit).map((pair, i) => (
          <dl
            key={i}
            className={classNames({ verified: pair.get('verified_at') })}
          >
            <EmojiHTML
              as='dt'
              htmlString={pair.get('name_emojified')}
              className='translate'
            />

            <dd className='translate' title={pair.get('value_plain') ?? ''}>
              {pair.get('verified_at') && (
                <Icon id='check' icon={CheckIcon} className='verified__mark' />
              )}
              <EmojiHTML as='span' htmlString={pair.get('value_emojified')} />
            </dd>
          </dl>
        ))}
      </CustomEmojiProvider>
    </div>
  );
};
