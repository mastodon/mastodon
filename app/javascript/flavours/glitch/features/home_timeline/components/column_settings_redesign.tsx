import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import type { Map as ImmutableMap } from 'immutable';

import { SlidersHorizontalIcon } from '@phosphor-icons/react';

import { ColumnSettingsMenu } from '@/flavours/glitch/components/column_header';
import { MenuItemCheckbox } from '@/flavours/glitch/components/menu';
import type { MenuItemCheckboxChangeHandler } from '@/flavours/glitch/components/menu/items';
import { useAppSelector, useAppDispatch } from 'flavours/glitch/store';

import { changeSetting } from '../../../actions/settings';

export const HomeColumnSettings: React.FC<{
  children?: React.ReactNode;
}> = ({ children }) => {
  const dispatch = useAppDispatch();

  const settings = useAppSelector((state) =>
    state.settings.get('home'),
  ) as ImmutableMap<string, unknown>;
  const onChange = useCallback<MenuItemCheckboxChangeHandler>(
    ({ value, checked }) => {
      dispatch(changeSetting(['home', 'shows', value], checked));
    },
    [dispatch],
  );

  const showBoosts = settings.getIn(['shows', 'reblog']) as boolean;
  const showQuotes = settings.getIn(['shows', 'quote']) as boolean;
  const showReplies = settings.getIn(['shows', 'reply']) as boolean;

  return (
    <ColumnSettingsMenu
      icon={SlidersHorizontalIcon}
      label={
        <FormattedMessage
          id='column.home_settings'
          defaultMessage='Home Settings'
        />
      }
    >
      <MenuItemCheckbox
        value='reblog'
        checked={showBoosts}
        onChange={onChange}
        keepMenuOpenOnClick
      >
        <FormattedMessage
          id='home.column_settings.show_reblogs'
          defaultMessage='Show boosts'
        />
      </MenuItemCheckbox>
      <MenuItemCheckbox
        value='quote'
        checked={showQuotes}
        onChange={onChange}
        keepMenuOpenOnClick
      >
        <FormattedMessage
          id='home.column_settings.show_quotes'
          defaultMessage='Show quotes'
        />
      </MenuItemCheckbox>
      <MenuItemCheckbox
        value='reply'
        checked={showReplies}
        onChange={onChange}
        keepMenuOpenOnClick
      >
        <FormattedMessage
          id='home.column_settings.show_replies'
          defaultMessage='Show replies'
        />
      </MenuItemCheckbox>
      {children}
    </ColumnSettingsMenu>
  );
};
