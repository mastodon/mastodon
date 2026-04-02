import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import type { Relationship } from '@/mastodon/models/relationship';

export const AccountInfo: FC<{ relationship?: Relationship }> = ({
  relationship,
}) => {
  if (!relationship) {
    return null;
  }
  return (
    <div className='account__header__info'>
      {(relationship.followed_by || relationship.requested_by) && (
        <span className='relationship-tag'>
          <AccountInfoFollower relationship={relationship} />
        </span>
      )}
      {relationship.blocking && (
        <span className='relationship-tag'>
          <FormattedMessage id='account.blocking' defaultMessage='Blocking' />
        </span>
      )}
      {relationship.muting && (
        <span key='muting' className='relationship-tag'>
          <FormattedMessage id='account.muting' defaultMessage='Muting' />
        </span>
      )}
      {relationship.domain_blocking && (
        <span key='domain_blocking' className='relationship-tag'>
          <FormattedMessage
            id='account.domain_blocking'
            defaultMessage='Blocking domain'
          />
        </span>
      )}
    </div>
  );
};

const AccountInfoFollower: FC<{ relationship: Relationship }> = ({
  relationship,
}) => {
  if (
    relationship.followed_by &&
    (relationship.following || relationship.requested)
  ) {
    return (
      <FormattedMessage
        id='account.mutual'
        defaultMessage='You follow each other'
      />
    );
  } else if (relationship.followed_by) {
    return (
      <FormattedMessage id='account.follows_you' defaultMessage='Follows you' />
    );
  } else if (relationship.requested_by) {
    return (
      <FormattedMessage
        id='account.requests_to_follow_you'
        defaultMessage='Requests to follow you'
      />
    );
  }
  return null;
};
