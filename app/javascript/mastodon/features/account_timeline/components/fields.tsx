import { useCallback, useMemo } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { openModal } from '@/mastodon/actions/modal';
import { AccountFields } from '@/mastodon/components/account_fields';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { FormattedDateWrapper } from '@/mastodon/components/formatted_date';
import { MiniCardList } from '@/mastodon/components/mini_card/list';
import { useElementHandledLink } from '@/mastodon/components/status/handled_link';
import { useAccount } from '@/mastodon/hooks/useAccount';
import type { Account } from '@/mastodon/models/account';
import { useAppDispatch } from '@/mastodon/store';

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
  const cards = useMemo(
    () =>
      account.fields.toArray().map(({ value_emojified, name_emojified }) => ({
        label: (
          <EmojiHTML
            htmlString={name_emojified}
            extraEmojis={account.emojis}
            className='translate'
            as='span'
            {...htmlHandlers}
          />
        ),
        value: (
          <EmojiHTML
            as='span'
            htmlString={value_emojified}
            extraEmojis={account.emojis}
            {...htmlHandlers}
          />
        ),
      })),
    [account.emojis, account.fields, htmlHandlers],
  );

  const dispatch = useAppDispatch();
  const handleOverflowClick = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'ACCOUNT_FIELDS',
        modalProps: { accountId: account.id },
      }),
    );
  }, [account.id, dispatch]);

  return (
    <MiniCardList
      cards={cards}
      className={classes.fieldList}
      onOverflowClick={handleOverflowClick}
    />
  );
};
