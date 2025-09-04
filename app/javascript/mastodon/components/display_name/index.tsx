import type { ComponentPropsWithoutRef, FC } from 'react';
import { useMemo } from 'react';

import classNames from 'classnames';
import type { LinkProps } from 'react-router-dom';
import { Link } from 'react-router-dom';

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
  className,
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
      <span {...props} className={classNames('display-name', className)}>
        <bdi>
          <strong className='display-name__html'>
            <Skeleton width='10ch' />
          </strong>
        </bdi>
        {!noDomain && (
          <span className='display-name__account'>
            &nbsp;
            <Skeleton width='7ch' />
          </span>
        )}
      </span>
    );
  }
  const accountName = isModernEmojiEnabled()
    ? account.get('display_name')
    : account.get('display_name_html');
  if (simple) {
    return (
      <bdi>
        <EmojiHTML {...props} htmlString={accountName} shallow as='span' />
      </bdi>
    );
  }

  return (
    <span {...props} className={classNames('display-name', className)}>
      <bdi>
        <EmojiHTML
          className='display-name__html'
          htmlString={accountName}
          shallow
          as='strong'
        />
      </bdi>
      {username && (
        <span className='display-name__account'>&nbsp;{username}</span>
      )}
    </span>
  );
};

export const LinkedDisplayName: FC<
  Props & { asProps?: ComponentPropsWithoutRef<'span'> } & Partial<LinkProps>
> = ({
  account,
  asProps = {},
  className,
  localDomain,
  simple,
  noDomain,
  ...linkProps
}) => {
  const displayProps = {
    account,
    className,
    localDomain,
    simple,
    noDomain,
    ...asProps,
  };
  if (!account) {
    return <DisplayName {...displayProps} />;
  }

  return (
    <Link
      to={`/@${account.acct}`}
      title={`@${account.acct}`}
      data-hover-card-account={account.id}
      {...linkProps}
    >
      <DisplayName {...displayProps} />
    </Link>
  );
};
