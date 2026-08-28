/* eslint-disable jsx-a11y/no-autofocus */
import type React from 'react';
import { lazy, Suspense, useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import {
  ChatCircleIcon,
  NewspaperIcon,
  PenNibIcon,
} from '@phosphor-icons/react';

import { IconButton } from '@/mastodon/components/button/redesign';
import { CircularProgress } from '@/mastodon/components/circular_progress';
import {
  Menu,
  MenuTrigger,
  MenuList,
  MenuItem,
} from '@/mastodon/components/menu';
import { MenuCard } from '@/mastodon/components/menu/card';
import { openNewComposer } from '@/mastodon/reducers/slices/composer';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { isRedesignEnabled } from '@/mastodon/utils/environment';

import { ComposeFormHeader } from './header';
import classes from './trigger.module.scss';

const ComposeLazyForm = lazy(() =>
  import('./index').then(({ RedesignComposeForm }) => ({
    default: RedesignComposeForm,
  })),
);

export const ComposeRedesignButton: React.FC<{
  /**
   * Render the button in regular document flow instead of fixed positioning for mobile layout
   */
  inline?: boolean;
}> = ({ inline }) => {
  const displayState = useAppSelector((state) => state.composer.displayState);

  const dispatch = useAppDispatch();
  const handleComposerOpen: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(
      (event) => {
        const {
          currentTarget: { name },
        } = event;
        if (name === 'post' || name === 'message') {
          dispatch(openNewComposer({ type: name }));
        }
      },
      [dispatch],
    );

  if (!isRedesignEnabled()) {
    return null;
  }

  if (displayState === 'minimized') {
    return (
      <MenuCard className={classes.composerMinimized} elevation={2}>
        <ComposeFormHeader />
      </MenuCard>
    );
  }

  if (displayState === 'showing') {
    return (
      <Suspense fallback={<CircularProgress strokeWidth={2} size={50} />}>
        <ComposeLazyForm autoFocus className={classes.composer} />
      </Suspense>
    );
  }

  return (
    <Menu>
      <MenuTrigger
        as={IconButton}
        icon={PenNibIcon}
        variant='solid'
        className={classNames(classes.button, inline && classes.buttonInline)}
        size='lg'
      >
        <FormattedMessage
          id='compose.new'
          defaultMessage='Write a new post or messsage'
        />
      </MenuTrigger>

      <MenuList maxWidth={180} placement='top-end'>
        <MenuItem name='post' onClick={handleComposerOpen} icon={NewspaperIcon}>
          <FormattedMessage id='compose.new.post' defaultMessage='Post' />
        </MenuItem>

        <MenuItem
          name='message'
          onClick={handleComposerOpen}
          icon={ChatCircleIcon}
        >
          <FormattedMessage
            id='compose.new.message'
            defaultMessage='Message'
            description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
          />
        </MenuItem>
      </MenuList>
    </Menu>
  );
};
