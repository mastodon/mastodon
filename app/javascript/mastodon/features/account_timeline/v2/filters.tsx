import { useCallback, useId, useRef, useState } from 'react';
import type { ChangeEventHandler, FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { useParams } from 'react-router';

import Overlay from 'react-overlays/esm/Overlay';

import { Toggle } from '@/mastodon/components/form_fields';
import { Icon } from '@/mastodon/components/icon';
import KeyboardArrowDownIcon from '@/material-icons/400-24px/keyboard_arrow_down.svg?react';

import { AccountTabs } from '../components/tabs';

import { useAccountContext } from './context';
import classes from './styles.module.scss';

export const AccountFilters: FC = () => {
  const { acct } = useParams<{ acct: string }>();
  if (!acct) {
    return null;
  }
  return (
    <>
      <AccountTabs acct={acct} />
      <div className={classes.filtersWrapper}>
        <FilterDropdown />
      </div>
    </>
  );
};

const FilterDropdown: FC = () => {
  const [open, setOpen] = useState(false);
  const buttonRef = useRef<HTMLButtonElement>(null);

  const handleClick = useCallback(() => {
    setOpen(true);
  }, []);
  const handleHide = useCallback(() => {
    setOpen(false);
  }, []);

  const { boosts, replies, setBoosts, setReplies } = useAccountContext();
  const handleChange: ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      const { name, checked } = event.target;
      if (name === 'boosts') {
        setBoosts(checked);
      } else if (name === 'replies') {
        setReplies(checked);
      }
    },
    [setBoosts, setReplies],
  );

  const accessibleId = useId();
  const containerRef = useRef<HTMLDivElement>(null);

  return (
    <div ref={containerRef}>
      <button
        type='button'
        className={classes.filterSelectButton}
        ref={buttonRef}
        onClick={handleClick}
        aria-expanded={open}
        aria-controls={`${accessibleId}-wrapper`}
      >
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
        <Icon
          id='unfold_more'
          icon={KeyboardArrowDownIcon}
          className={classes.filterSelectIcon}
        />
      </button>
      <Overlay
        show={open}
        target={buttonRef}
        placement='bottom-start'
        rootClose
        onHide={handleHide}
        container={containerRef}
      >
        {({ props }) => (
          <div
            {...props}
            id={`${accessibleId}-wrapper`}
            className={classes.filterOverlay}
          >
            <label htmlFor={`${accessibleId}-replies`}>
              <FormattedMessage
                id='account.filters.replies_toggle'
                defaultMessage='Show replies'
              />
            </label>
            <Toggle
              name='replies'
              checked={replies}
              onChange={handleChange}
              id={`${accessibleId}-replies`}
            />

            <label htmlFor={`${accessibleId}-boosts`}>
              <FormattedMessage
                id='account.filters.boosts_toggle'
                defaultMessage='Show boosts'
              />
            </label>
            <Toggle
              name='boosts'
              checked={boosts}
              onChange={handleChange}
              id={`${accessibleId}-boosts`}
            />
          </div>
        )}
      </Overlay>
    </div>
  );
};
