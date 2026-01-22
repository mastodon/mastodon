import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { useParams } from 'react-router';

import type { AccountTimelineParams } from '@/mastodon/actions/timelines_typed';
import { Icon } from '@/mastodon/components/icon';
import KeyboardArrowDownIcon from '@/material-icons/400-24px/keyboard_arrow_down.svg?react';

import { AccountTabs } from '../components/tabs';
import classes from '../redesign.module.scss';

export const AccountFilters: FC<{ params: AccountTimelineParams }> = ({
  params,
}) => {
  const { acct } = useParams<{ acct: string }>();
  if (!acct) {
    return null;
  }
  return (
    <>
      <AccountTabs acct={acct} />
      <div className={classes.filters}>
        <FilterDropdown params={params} />
      </div>
    </>
  );
};

const FilterDropdown: FC<{ params: AccountTimelineParams }> = ({
  params: { boosts, replies },
}) => {
  return (
    <button type='button'>
      {boosts && replies && (
        <FormattedMessage
          id='account.filters.all'
          defaultMessage='All activity'
        />
      )}
      {!boosts && replies && (
        <FormattedMessage
          id='account.filters.posts_replies'
          defaultMessage='Posts and replies'
        />
      )}
      {boosts && !replies && (
        <FormattedMessage
          id='account.filters.posts_boosts'
          defaultMessage='Posts and boosts'
        />
      )}
      {!boosts && !replies && (
        <FormattedMessage
          id='account.filters.posts_only'
          defaultMessage='Posts'
        />
      )}
      <Icon id='unfold_more' icon={KeyboardArrowDownIcon} />
    </button>
  );
};
