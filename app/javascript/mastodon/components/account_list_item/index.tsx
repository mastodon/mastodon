import { Account } from 'mastodon/components/account';
import { useAccount } from 'mastodon/hooks/useAccount';
import { useRelationship } from 'mastodon/hooks/useRelationship';
import type { Relationship } from 'mastodon/models/relationship';

import { FamiliarFollowers } from '../familiar_followers';
import { FollowButton } from '../follow_button';

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

export const AccountListItem: React.FC<Props> = ({
  accountId,
  withBorder = true,
  renderButton = defaultRenderButton,
}) => {
  const account = useAccount(accountId);
  const relationship = useRelationship(accountId);

  if (!accountId || !account) {
    return null;
  }

  return (
    <div className={classes.wrapper} data-with-border={withBorder}>
      <Account
        minimal
        withBio
        withMenu={false}
        withBorder={false}
        id={accountId}
        className={classes.account}
        extraAccountInfo={
          <div className={classes.extraInfo}>
            <FamiliarFollowers accountId={accountId} />
          </div>
        }
      />
      {renderButton({ accountId, relationship })}
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
