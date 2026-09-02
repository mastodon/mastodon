import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { SlidersHorizontalIcon } from '@phosphor-icons/react';

import { ColumnSettingsMenu } from '@/mastodon/components/column_header';
import { MenuItemCheckbox } from '@/mastodon/components/menu';
import type { MenuItemCheckboxChangeHandler } from '@/mastodon/components/menu/items';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { changeSetting } from '../../../actions/settings';

export const HomeColumnSettings: React.FC<{
  children?: React.ReactNode;
}> = ({ children }) => {
  const dispatch = useAppDispatch();

  const settings = useAppSelector((state) => state.settings.get('home'));
  const onChange = useCallback<MenuItemCheckboxChangeHandler>(
    ({ value, checked }) => {
      dispatch(changeSetting(['home', 'shows', value], checked));
    },
    [dispatch],
  );

  /* eslint-disable @typescript-eslint/no-unsafe-call */
  // @ts-expect-error settings isn't typed yet
  const showBoosts = settings.getIn(['shows', 'reblog']) as boolean;
  // @ts-expect-error settings isn't typed yet
  const showQuotes = settings.getIn(['shows', 'quote']) as boolean;
  // @ts-expect-error settings isn't typed yet
  const showReplies = settings.getIn(['shows', 'reply']) as boolean;
  /* eslint-enable @typescript-eslint/no-unsafe-call */

  return (
    <ColumnSettingsMenu
      icon={SlidersHorizontalIcon}
      label={
        <FormattedMessage id='home.settings' defaultMessage='Home Settings' />
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
