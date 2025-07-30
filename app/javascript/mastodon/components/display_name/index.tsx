import type { ComponentPropsWithoutRef, FC } from 'react';
import { useMemo } from 'react';

import { EmojiHTML } from '@/mastodon/features/emoji/emoji_html';
import type { Account } from '@/mastodon/models/account';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

import { Skeleton } from '../skeleton';

interface Props {
  account?: Account;
  localDomain?: string;
  simple?: boolean;
  noDomain?: boolean;
}

export const DisplayName: FC<Props & ComponentPropsWithoutRef<'span'>> = ({
  account,
  localDomain,
  simple = false,
  noDomain = false,
  className = '',
  ...props
}) => {
  const username = useMemo(() => {
    if (!account || noDomain) {
      return null;
    }
    let acct = account.get('acct');

    if (!acct.includes('@') && localDomain) {
      acct = `${acct}@${localDomain}`;
    }
    return `@${acct}`;
  }, [account, localDomain, noDomain]);
  if (!account) {
    if (simple) {
      return null;
    }
    return (
      <span {...props} className={`display-name ${className}`}>
        <bdi>
          <strong className='display-name__html'>
            <Skeleton width='10ch' />
          </strong>
        </bdi>
        {!noDomain && (
          <span className='display-name__account'>
            <Skeleton width='7ch' />
          </span>
        )}
      </span>
    );
  }
  if (simple) {
    return (
      <EmojiHTML
        {...props}
        htmlString={
          isModernEmojiEnabled()
            ? account.get('display_name')
            : account.get('display_name_html')
        }
        shallow
        as='span'
      />
    );
  }
  return (
    <span {...props} className={`display-name ${className}`}>
      <bdi>
        <EmojiHTML
          {...props}
          className={`display-name__html ${className}`}
          htmlString={
            isModernEmojiEnabled()
              ? account.get('display_name')
              : account.get('display_name_html')
          }
          shallow
          as='strong'
        />
      </bdi>
      {username && <span className='display-name__account'>{username}</span>}
    </span>
  );
};
