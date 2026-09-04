import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import type {
  List as ImmutableList,
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

export const FeedColumnSettings: React.FC<{
  columnId: string | undefined;
  localOnly?: boolean;
}> = ({ columnId, localOnly }) => {
  const dispatch = useAppDispatch();

  const settings = useAppSelector((state) => {
    const columns = state.settings.get('columns') as Columns;
    const index = columns.findIndex((c) => c.get('uuid') === columnId);

    return columnId && index >= 0
      ? columns.get(index)?.get('params')
      : state.settings.get('public');
  });

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

  /* eslint-disable @typescript-eslint/no-unsafe-call */
  // @ts-expect-error settings isn't typed yet
  const onlyMedia = settings.getIn(['other', 'onlyMedia']) as boolean;
  // @ts-expect-error settings isn't typed yet
  const onlyRemote = settings.getIn(['other', 'onlyRemote']) as boolean;
  /* eslint-enable @typescript-eslint/no-unsafe-call */

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
