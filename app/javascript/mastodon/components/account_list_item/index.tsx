import { FormattedMessage, useIntl } from 'react-intl';

import { Account } from 'mastodon/components/account';
import { VerifiedBadge } from 'mastodon/components/badge';
import { useAccount } from 'mastodon/hooks/useAccount';
import { useRelationship } from 'mastodon/hooks/useRelationship';
import type { Relationship } from 'mastodon/models/relationship';

import { EmojiHTML } from '../emoji/html';
import { FamiliarFollowers } from '../familiar_followers';
import { FollowButton } from '../follow_button';
import { NumberFields, NumberFieldsItem } from '../number_fields';
import { RelativeTimestamp } from '../relative_timestamp';
import { ShortNumber } from '../short_number';

import classes from './styles.module.scss';

export interface RenderButtonOptions {
  accountId: string | undefined;
  relationship: Relationship | null | undefined;
}

interface Props {
  accountId: string | undefined;
  renderButton?: (options: RenderButtonOptions) => React.ReactNode;
  withBorder?: boolean;
}

/**
 * Extended account list item with bio, verified link badges,
 * and familiar follower widget.
 *
 * The button rendering can be customised via the `renderButton` prop.
 */
export const AccountListItem: React.FC<Props> = ({
  accountId,
  withBorder = true,
  renderButton = defaultRenderButton,
}) => {
  const intl = useIntl();
  const account = useAccount(accountId);
  const relationship = useRelationship(accountId);

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

        <NumberFieldsItem
          label={
            <FormattedMessage
              id='account.last_active'
              defaultMessage='Last active'
            />
          }
        >
          <RelativeTimestamp long timestamp={account.last_status_at} noFuture />
        </NumberFieldsItem>
        {firstVerifiedField && (
          <VerifiedBadge
            link={firstVerifiedField.value}
            className={classes.verifiedBadge}
          />
        )}
      </NumberFields>
      <FamiliarFollowers accountId={accountId} />
      {account.note.length > 0 && (
        <EmojiHTML
          className='translate'
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
