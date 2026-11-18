import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { PushPinIcon } from '@phosphor-icons/react';

import { Button } from '@/mastodon/components/button';

import { useAccountContext } from '../hooks/useAccountContext';
import classes from '../styles.module.scss';

export const PinnedShowAllButton: FC = () => {
  const { onShowAllPinned } = useAccountContext();

  return (
    <Button
      onClick={onShowAllPinned}
      className={classNames(classes.pinnedViewAllButton, 'focusable')}
      leadingIcon={PushPinIcon}
      color='accent'
    >
      <FormattedMessage
        id='account.timeline.pinned.view_all'
        defaultMessage='View all pinned posts'
      />
    </Button>
  );
};
