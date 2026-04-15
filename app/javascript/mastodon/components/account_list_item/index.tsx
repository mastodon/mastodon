import { useMemo } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { Account } from 'mastodon/components/account';
import { VerifiedBadge } from 'mastodon/components/badge';
import { useAccount } from 'mastodon/hooks/useAccount';
import { useRelationship } from 'mastodon/hooks/useRelationship';
import type { Relationship } from 'mastodon/models/relationship';

import { EmojiHTML } from '../emoji/html';
import { FollowButton } from '../follow_button';
import { FormattedDateWrapper } from '../formatted_date';
import { NumberFields, NumberFieldsItem } from '../number_fields';
import { RelativeTimestamp } from '../relative_timestamp';
import { ShortNumber } from '../short_number';

import classes from './styles.module.scss';

export interface RenderButtonOptions {
  accountId: string | undefined;
  relationship: Relationship | null | undefined;
}

type Stat = 'followers' | 'following' | 'posts' | 'joined' | 'last-active';

interface Props {
  accountId: string | undefined;
  stats?: Stat[];
  renderButton?: (options: RenderButtonOptions) => React.ReactNode;
  withBio?: boolean;
  withBorder?: boolean;
}

const DEFAULT_STATS: Stat[] = ['followers', 'posts', 'last-active'];

/**
 * Extended account list item with bio, verified link badge,
 * and familiar follower widget.
 *
 * The displayed account stats can be customised using the `stats` prop,
 * and button rendering can be customised via the `renderButton` prop.
 */
export const AccountListItem: React.FC<Props> = ({
  accountId,
  stats = DEFAULT_STATS,
  withBio = true,
  withBorder = true,
  renderButton = defaultRenderButton,
}) => {
  const intl = useIntl();
  const account = useAccount(accountId);
  const relationship = useRelationship(accountId);

  const createdThisYear = useMemo(
    () => account?.created_at.includes(new Date().getFullYear().toString()),
    [account?.created_at],
  );

  if (!accountId || !account) {
    return null;
  }

  const firstVerifiedField = account.fields.find((item) => !!item.verified_at);

  return (
    <div className={classes.wrapper} data-with-border={withBorder}>
      <div className={classes.header}>
        <Account
          id={accountId}
          minimal
          size={40}
          withMenu={false}
          withBorder={false}
          className={classes.account}
        />

        {renderButton({ accountId, relationship })}
      </div>

      <NumberFields>
        {stats.includes('followers') && (
          <NumberFieldsItem
            label={
              <FormattedMessage
                id='account.followers'
                defaultMessage='Followers'
              />
            }
            hint={intl.formatNumber(account.followers_count)}
          >
            <ShortNumber value={account.followers_count} />
          </NumberFieldsItem>
        )}
        {stats.includes('following') && (
          <NumberFieldsItem
            label={
              <FormattedMessage
                id='account.following'
                defaultMessage='Following'
              />
            }
            hint={intl.formatNumber(account.following_count)}
            link={`/@${account.acct}/following`}
          >
            <ShortNumber value={account.following_count} />
          </NumberFieldsItem>
        )}
        {stats.includes('posts') && (
          <NumberFieldsItem
            label={
              <FormattedMessage id='account.posts' defaultMessage='Posts' />
            }
            hint={intl.formatNumber(account.statuses_count)}
          >
            <ShortNumber value={account.statuses_count} />
          </NumberFieldsItem>
        )}
        {stats.includes('joined') && (
          <NumberFieldsItem
            label={
              <FormattedMessage
                id='account.joined_short'
                defaultMessage='Joined'
              />
            }
            hint={intl.formatDate(account.created_at)}
          >
            {createdThisYear ? (
              <FormattedDateWrapper
                value={account.created_at}
                month='short'
                day='2-digit'
              />
            ) : (
              <FormattedDateWrapper value={account.created_at} year='numeric' />
            )}
          </NumberFieldsItem>
        )}
        {stats.includes('last-active') && (
          <NumberFieldsItem
            label={
              <FormattedMessage
                id='account.last_active'
                defaultMessage='Last active'
              />
            }
          >
            {account.last_status_at ? (
              <RelativeTimestamp long timestamp={account.last_status_at} />
            ) : (
              '-'
            )}
          </NumberFieldsItem>
        )}
        {firstVerifiedField && (
          <VerifiedBadge
            link={firstVerifiedField.value}
            className={classes.verifiedBadge}
          />
        )}
      </NumberFields>
      {withBio && account.note.length > 0 && (
        <EmojiHTML
          className={classNames(classes.bio, 'translate')}
          htmlString={account.note_emojified}
          extraEmojis={account.emojis}
        />
      )}
    </div>
  );
};

const defaultRenderButton = ({ accountId }: RenderButtonOptions) => (
  <AccountListItemFollowButton accountId={accountId} />
);

export const AccountListItemFollowButton: React.FC<{
  accountId: string | undefined;
}> = ({ accountId }) => (
  <FollowButton compact labelLength='short' accountId={accountId} />
);
