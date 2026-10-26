import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { changeColumnParams } from '@/flavours/glitch/actions/columns';
import { openModal } from '@/flavours/glitch/actions/modal';
import { ColumnSettingsMenu } from '@/flavours/glitch/components/column_header';
import { MultiColumnMenuItems } from '@/flavours/glitch/components/column_header/multicolumn_settings';
import {
  MenuItem,
  MenuItemCheckbox,
  MenuItemDivider,
} from '@/flavours/glitch/components/menu';
import type { MenuItemCheckboxChangeHandler } from '@/flavours/glitch/components/menu/items';
import { useHashtag } from '@/flavours/glitch/hooks/useHashtag';
import { useIdentity } from '@/flavours/glitch/identity_context';
import { useAppDispatch } from 'flavours/glitch/store';

import { useColumnSettings } from '../../public_timeline/components/feed_column_settings';

import { messages } from './hashtag_header';

export const HashtagColumnMenu: React.FC<{
  tagId: string;
  multiColumn?: boolean;
  columnId?: string;
  onPin: () => void;
  onMove: (dir: number) => void;
}> = ({ tagId, multiColumn, columnId, onPin, onMove }) => {
  const dispatch = useAppDispatch();
  const { signedIn } = useIdentity();

  const { tag, toggleFollow, toggleFeature } = useHashtag(tagId);

  const columnSettings = useColumnSettings(columnId);
  const isLocalOnly = columnSettings.get('local') as boolean;
  const toggleIsLocalOnly = useCallback<MenuItemCheckboxChangeHandler>(
    ({ checked }) => {
      dispatch(changeColumnParams(columnId, ['local'], checked));
    },
    [columnId, dispatch],
  );

  const openAdvancedSettings = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'HASHTAG_SETTINGS',
        modalProps: { columnId },
      }),
    );
  }, [columnId, dispatch]);

  if (!tag || !signedIn) {
    return null;
  }

  const pinned = !!columnId;

  return (
    <ColumnSettingsMenu
      label={
        <FormattedMessage
          id='hashtag.options'
          defaultMessage='Hashtag options'
        />
      }
    >
      <MenuItem onClick={toggleFollow}>
        {tag.following ? (
          <FormattedMessage {...messages.unfollowHashtag} />
        ) : (
          <FormattedMessage {...messages.followHashtag} />
        )}
      </MenuItem>
      <MenuItem onClick={toggleFeature}>
        {tag.featuring ? (
          <FormattedMessage {...messages.unfeature} />
        ) : (
          <FormattedMessage {...messages.feature} />
        )}
      </MenuItem>
      {multiColumn && pinned && (
        <>
          <MenuItemDivider />
          <MenuItemCheckbox
            value='local'
            checked={isLocalOnly}
            onChange={toggleIsLocalOnly}
            keepMenuOpenOnClick
          >
            <FormattedMessage
              id='community.column_settings.local_only'
              defaultMessage='Local only'
            />
          </MenuItemCheckbox>
          <MenuItem onClick={openAdvancedSettings}>
            <FormattedMessage
              id='hashtags.add_more_tags'
              defaultMessage='Add more tags to this column…'
            />
          </MenuItem>
        </>
      )}
      {multiColumn && (
        <MultiColumnMenuItems
          withDivider
          pinned={pinned}
          onPin={onPin}
          onMove={onMove}
        />
      )}
    </ColumnSettingsMenu>
  );
};
