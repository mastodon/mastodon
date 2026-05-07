import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import IconPinned from '@/images/icons/icon_pinned.svg?react';
import { Badge } from '@/mastodon/components/badge';
import { Button } from '@/mastodon/components/button';
import { Icon } from '@/mastodon/components/icon';
import { StatusHeader } from '@/mastodon/components/status/header';
import type { StatusHeaderRenderFn } from '@/mastodon/components/status/header';

import { useAccountContext } from '../hooks/useAccountContext';
import classes from '../styles.module.scss';

export const renderPinnedStatusHeader: StatusHeaderRenderFn = ({
  featured,
  ...args
}) => {
  if (!featured) {
    return <StatusHeader {...args} />;
  }
  return (
    <StatusHeader {...args} className={classes.pinnedStatusHeader}>
      <Badge
        className={classes.pinnedBadge}
        icon={<Icon id='pinned' icon={IconPinned} />}
        label={
          <FormattedMessage
            id='account.timeline.pinned'
            defaultMessage='Pinned'
          />
        }
      />
    </StatusHeader>
  );
};

export const PinnedShowAllButton: FC = () => {
  const { onShowAllPinned } = useAccountContext();

  return (
    <Button
      onClick={onShowAllPinned}
      className={classNames(classes.pinnedViewAllButton, 'focusable')}
    >
      <Icon id='pinned' icon={IconPinned} />
      <FormattedMessage
        id='account.timeline.pinned.view_all'
        defaultMessage='View all pinned posts'
      />
    </Button>
  );
};
