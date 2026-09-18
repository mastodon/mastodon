import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import type {
  List as ImmutableList,
  Map as ImmutableMap,
  Record as ImmutableRecord,
} from 'immutable';

import { changeColumnParams } from '@/mastodon/actions/columns';
import { MenuItemCheckbox } from '@/mastodon/components/menu';
import type { MenuItemCheckboxChangeHandler } from '@/mastodon/components/menu/items';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { changeSetting } from '../../../actions/settings';

type Columns = ImmutableList<
  ImmutableRecord<{
    uuid: string;
    params?: string;
  }>
>;

export function useColumnSettings(columnId: string | undefined) {
  return useAppSelector((state) => {
    const columns = state.settings.get('columns') as Columns;
    const index = columns.findIndex((c) => c.get('uuid') === columnId);

    return columnId && index >= 0
      ? columns.get(index)?.get('params')
      : state.settings.get('public');
  }) as ImmutableMap<string, unknown>;
}

export const FeedColumnSettings: React.FC<{
  columnId: string | undefined;
  localOnly?: boolean;
}> = ({ columnId, localOnly }) => {
  const dispatch = useAppDispatch();

  const settings = useColumnSettings(columnId);

  const onChange = useCallback<MenuItemCheckboxChangeHandler>(
    ({ value, checked }) => {
      if (columnId) {
        dispatch(changeColumnParams(columnId, ['other', value], checked));
      } else {
        dispatch(changeSetting(['public', 'other', value], checked));
      }
    },
    [columnId, dispatch],
  );

  const onlyMedia = settings.getIn(['other', 'onlyMedia']) as boolean;
  const onlyRemote = settings.getIn(['other', 'onlyRemote']) as boolean;

  return (
    <>
      <MenuItemCheckbox
        value='onlyMedia'
        checked={onlyMedia}
        onChange={onChange}
        keepMenuOpenOnClick
      >
        <FormattedMessage
          id='community.column_settings.media_only'
          defaultMessage='Media only'
        />
      </MenuItemCheckbox>
      {!localOnly && (
        <MenuItemCheckbox
          value='onlyRemote'
          checked={onlyRemote}
          onChange={onChange}
          keepMenuOpenOnClick
        >
          <FormattedMessage
            id='community.column_settings.remote_only'
            defaultMessage='Remote only'
          />
        </MenuItemCheckbox>
      )}
    </>
  );
};
