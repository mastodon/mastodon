import type { FC } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import IconVerified from '@/images/icons/icon_verified.svg?react';
import { AccountFields } from '@/mastodon/components/account_fields';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { FormattedDateWrapper } from '@/mastodon/components/formatted_date';
import { IconButton } from '@/mastodon/components/icon_button';
import { MiniCard } from '@/mastodon/components/mini_card';
import { useElementHandledLink } from '@/mastodon/components/status/handled_link';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useOverflowScroll } from '@/mastodon/hooks/useOverflow';
import type { Account } from '@/mastodon/models/account';
import { isValidUrl } from '@/mastodon/utils/checks';
import IconLeftArrow from '@/material-icons/400-24px/chevron_left.svg?react';
import IconRightArrow from '@/material-icons/400-24px/chevron_right.svg?react';
import IconLink from '@/material-icons/400-24px/link_2.svg?react';

import { isRedesignEnabled } from '../common';

import classes from './redesign.module.scss';

export const AccountHeaderFields: FC<{ accountId: string }> = ({
  accountId,
}) => {
  const account = useAccount(accountId);

  if (!account) {
    return null;
  }

  if (isRedesignEnabled()) {
    return <RedesignAccountHeaderFields account={account} />;
  }

  return (
    <div className='account__header__fields'>
      <dl>
        <dt>
          <FormattedMessage id='account.joined_short' defaultMessage='Joined' />
        </dt>
        <dd>
          <FormattedDateWrapper
            value={account.created_at}
            year='numeric'
            month='short'
            day='2-digit'
          />
        </dd>
      </dl>

      <AccountFields fields={account.fields} emojis={account.emojis} />
    </div>
  );
};

const RedesignAccountHeaderFields: FC<{ account: Account }> = ({ account }) => {
  const htmlHandlers = useElementHandledLink();
  const intl = useIntl();

  const {
    bodyRef,
    canScrollLeft,
    canScrollRight,
    handleLeftNav,
    handleRightNav,
    handleScroll,
  } = useOverflowScroll();

  return (
    <div
      className={classNames(
        classes.fieldWrapper,
        canScrollLeft && classes.fieldWrapperLeft,
        canScrollRight && classes.fieldWrapperRight,
      )}
    >
      {canScrollLeft && (
        <IconButton
          icon='more'
          iconComponent={IconLeftArrow}
          title={intl.formatMessage({
            id: 'account.fields.scroll_prev',
            defaultMessage: 'Show previous',
          })}
          className={classes.fieldArrowButton}
          onClick={handleLeftNav}
        />
      )}
      <dl ref={bodyRef} className={classes.fieldList} onScroll={handleScroll}>
        {account.fields.map(
          (
            { name, name_emojified, value_emojified, value_plain, verified_at },
            key,
          ) => (
            <MiniCard
              key={key}
              label={
                <EmojiHTML
                  htmlString={name_emojified}
                  extraEmojis={account.emojis}
                  className='translate'
                  as='span'
                  title={name}
                  {...htmlHandlers}
                />
              }
              value={
                <EmojiHTML
                  as='span'
                  htmlString={value_emojified}
                  extraEmojis={account.emojis}
                  title={value_plain ?? undefined}
                  {...htmlHandlers}
                />
              }
              icon={fieldIcon(verified_at, value_plain)}
              className={classNames(
                classes.fieldCard,
                verified_at && classes.fieldCardVerified,
              )}
            />
          ),
        )}
      </dl>
      {canScrollRight && (
        <IconButton
          icon='more'
          iconComponent={IconRightArrow}
          title={intl.formatMessage({
            id: 'account.fields.scroll_next',
            defaultMessage: 'Show next',
          })}
          className={classes.fieldArrowButton}
          onClick={handleRightNav}
        />
      )}
    </div>
  );
};

function fieldIcon(verified_at: string | null, value_plain: string | null) {
  if (verified_at) {
    return IconVerified;
  } else if (value_plain && isValidUrl(value_plain)) {
    return IconLink;
  }
  return undefined;
}
