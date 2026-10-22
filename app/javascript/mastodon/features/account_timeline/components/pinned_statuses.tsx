import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import IconPinned from '@/images/icons/icon_pinned.svg?react';
import { Button } from '@/mastodon/components/button';
import { Icon } from '@/mastodon/components/icon';

import { useAccountContext } from '../hooks/useAccountContext';
import classes from '../styles.module.scss';

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
