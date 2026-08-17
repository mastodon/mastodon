import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import type { NavLinkProps } from 'react-router-dom';

import { useAccount } from '@/mastodon/hooks/useAccount';
import { useAccountId } from '@/mastodon/hooks/useAccountId';

import { TabLink, TabList } from '../tab_list';

import classes from './styles.module.scss';

const isActive: Required<NavLinkProps>['isActive'] = (match, location) =>
  match?.url === location.pathname ||
  (!!match?.url && location.pathname.startsWith(`${match.url}/tagged/`));

export const AccountTabs: FC = () => {
  const accountId = useAccountId();
  const account = useAccount(accountId);

  if (!account) {
    return <hr className={classes.noTabs} />;
  }

  const {
    acct,
    show_featured,
    show_media,
    can_create_statuses,
    can_reply_to_statuses,
    can_reblog_statuses,
  } = account;

  // highlander: readers without posting permissions (e.g. the Poster role
  // requirement) shouldn't see tabs for content they can't produce.
  const canActivity =
    can_create_statuses || can_reblog_statuses || can_reply_to_statuses;
  const canMedia = can_create_statuses || can_reply_to_statuses;
  const canFeatured = show_featured && can_create_statuses;
  const canShowMedia = show_media && canMedia;

  if (!canFeatured && !canShowMedia && !canActivity) {
    return <hr className={classes.noTabs} />;
  }

  return (
    <TabList>
      {canActivity && (
        <TabLink isActive={isActive} to={`/@${acct}`}>
          <FormattedMessage id='account.activity' defaultMessage='Activity' />
        </TabLink>
      )}
      {canShowMedia && (
        <TabLink exact to={`/@${acct}/media`}>
          <FormattedMessage id='account.media' defaultMessage='Media' />
        </TabLink>
      )}
      {canFeatured && (
        <TabLink exact to={`/@${acct}/featured`}>
          <FormattedMessage id='account.featured' defaultMessage='Featured' />
        </TabLink>
      )}
    </TabList>
  );
};
