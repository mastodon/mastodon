/* eslint-disable jsx-a11y/no-autofocus */
import type React from 'react';
import { lazy, Suspense, useCallback, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  ChatCircleIcon,
  NewspaperIcon,
  PenNibIcon,
} from '@phosphor-icons/react';

import { openNewComposer } from '@/mastodon/actions/compose_typed';
import { IconButton } from '@/mastodon/components/button/redesign';
import { CircularProgress } from '@/mastodon/components/circular_progress';
import {
  DropdownItemButton,
  DropdownPopover,
} from '@/mastodon/components/dropdown/redesign';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { isRedesignEnabled } from '@/mastodon/utils/environment';

import classes from './trigger.module.scss';

export const ComposeRedesignButton: React.FC = () => {
  const [ref, setRef] = useState<HTMLButtonElement | null>(null);
  const [menuOpen, { onFalse: onMenuClose, onToggle: onMenuToggle }] =
    useToggle();
  const isComposerOpen = useAppSelector(
    (state) => !!state.compose.get('showNewComposer'),
  );

  const dispatch = useAppDispatch();
  const handleComposerOpen: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(
      (event) => {
        const {
          currentTarget: { name },
        } = event;
        if (name === 'post' || name === 'message') {
          dispatch(openNewComposer({ type: name }));
          onMenuClose();
        }
      },
      [dispatch, onMenuClose],
    );

  if (!isRedesignEnabled()) {
    return null;
  }

  if (isComposerOpen) {
    return <ComposeRedesignModal />;
  }

  return (
    <>
      <IconButton
        icon={PenNibIcon}
        color='neutral'
        ref={setRef}
        onClick={onMenuToggle}
        className={classes.button}
        size='lg'
      >
        <FormattedMessage
          id='compose.new'
          defaultMessage='Write a new post or messsage'
        />
      </IconButton>

      <DropdownPopover
        isOpen={menuOpen}
        maxWidth={180}
        reference={ref}
        onClose={onMenuClose}
        placement='top-end'
      >
        <DropdownItemButton
          name='post'
          onClick={handleComposerOpen}
          leadingIcon={NewspaperIcon}
        >
          <FormattedMessage id='compose.new.post' defaultMessage='Post' />
        </DropdownItemButton>
        <DropdownItemButton
          name='message'
          onClick={handleComposerOpen}
          leadingIcon={ChatCircleIcon}
        >
          <FormattedMessage id='compose.new.message' defaultMessage='Message' />
        </DropdownItemButton>
      </DropdownPopover>
    </>
  );
};

const ComposeLazyForm = lazy(() =>
  import('./index').then(({ RedesignComposeForm }) => ({
    default: RedesignComposeForm,
  })),
);

const ComposeRedesignModal: React.FC = () => {
  return (
    <div className={classes.composer}>
      <Suspense fallback={<CircularProgress strokeWidth={2} size={50} />}>
        <ComposeLazyForm autoFocus />
      </Suspense>
    </div>
  );
};
