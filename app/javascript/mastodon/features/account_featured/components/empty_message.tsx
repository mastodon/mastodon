import { FormattedMessage } from 'react-intl';

import { useParams } from 'react-router';
import { Link } from 'react-router-dom';

import ElephantDarkImage from '@/images/elephant_ui_dark.svg?react';
import ElephantLightImage from '@/images/elephant_ui_light.svg?react';
import { LimitedAccountHint } from '@/mastodon/features/account_timeline/components/limited_account_hint';
import { areCollectionsEnabled } from '@/mastodon/features/collections/utils';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { useTheme } from '@/mastodon/hooks/useTheme';

import classes from './styles.module.scss';

interface EmptyMessageProps {
  suspended: boolean;
  hidden: boolean;
  blockedBy: boolean;
  accountId?: string;
}

export const EmptyMessage: React.FC<EmptyMessageProps> = ({
  accountId,
  suspended,
  hidden,
  blockedBy,
}) => {
  const { acct } = useParams<{ acct?: string }>();
  const me = useCurrentAccountId();
  const theme = useTheme();
  const ElephantImage =
    theme === 'dark' ? ElephantDarkImage : ElephantLightImage;

  if (!accountId) {
    return null;
  }

  let title: React.ReactNode = null;
  let message: React.ReactNode = null;

  const hasCollections = areCollectionsEnabled();

  if (me === accountId) {
    if (hasCollections) {
      title = (
        <FormattedMessage
          id='empty_column.account_featured_self.no_collections'
          defaultMessage='No collections yet'
        />
      );
      message = (
        <Link to='/collections/new' className='button'>
          <FormattedMessage
            id='empty_column.account_featured_self.no_collections_button'
            defaultMessage='Create a collection'
          />
        </Link>
      );
    } else {
      title = (
        <FormattedMessage
          id='empty_column.account_featured_self.pre_collections'
          defaultMessage='Stay tuned for Collections'
        />
      );
      message = (
        <FormattedMessage
          id='empty_column.account_featured_self.pre_collections_desc'
          defaultMessage='Collections (coming in Mastodon 4.6) allows you to create your own curated lists of accounts to recommend to others.'
        />
      );
    }
  } else if (suspended) {
    title = (
      <FormattedMessage
        id='empty_column.account_suspended'
        defaultMessage='Account suspended'
      />
    );
  } else if (hidden) {
    message = <LimitedAccountHint accountId={accountId} />;
  } else if (blockedBy) {
    title = (
      <FormattedMessage
        id='empty_column.account_unavailable'
        defaultMessage='Profile unavailable'
      />
    );
  } else {
    // Standard other account empty state.
    title = (
      <FormattedMessage
        id='empty_column.account_featured_other.title'
        defaultMessage='Nothing to see here'
      />
    );
    if (hasCollections) {
      if (acct) {
        message = (
          <FormattedMessage
            id='empty_column.account_featured_other.no_collections_desc'
            defaultMessage='{acct} hasn’t created any collections yet.'
            values={{ acct }}
          />
        );
      } else {
        message = (
          <FormattedMessage
            id='empty_column.account_featured_unknown.no_collections_desc'
            defaultMessage='This account hasn’t created any collections yet.'
          />
        );
      }
    } else {
      if (acct) {
        message = (
          <FormattedMessage
            id='empty_column.account_featured.other'
            defaultMessage='{acct} hasn’t featured anything yet.'
            values={{ acct }}
          />
        );
      } else {
        message = (
          <FormattedMessage
            id='empty_column.account_featured_unknown.other'
            defaultMessage='This account hasn’t featured anything yet.'
          />
        );
      }
    }
  }

  return (
    <div className='empty-column-indicator'>
      <div className={classes.emptyWrapper}>
        <ElephantImage />
        {title && <h2>{title}</h2>}
        {message && <p>{message}</p>}
      </div>
    </div>
  );
};
