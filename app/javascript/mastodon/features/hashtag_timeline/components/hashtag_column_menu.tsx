import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { ColumnSettingsMenu } from '@/mastodon/components/column_header';
import { MultiColumnMenuItems } from '@/mastodon/components/column_header/multicolumn_settings';
import { MenuItem } from '@/mastodon/components/menu';
import { useIdentity } from '@/mastodon/identity_context';
import { useAppDispatch } from 'mastodon/store';

import { changeSetting } from '../../../actions/settings';

import { useHashtag, messages } from './hashtag_header';

export const HashtagColumnMenu: React.FC<{
  tagId: string;
  multiColumn?: boolean;
  pinned: boolean;
  onPin: () => void;
  onMove: (dir: number) => void;
}> = ({ tagId, multiColumn, pinned, onPin, onMove }) => {
  const dispatch = useAppDispatch();
  const { signedIn } = useIdentity();

  const { tag, toggleFollow, toggleFeature } = useHashtag(tagId);

  const openAdvancedSettings = useCallback(() => {
    dispatch(changeSetting(['public', 'other']));
  }, [dispatch]);

  if (!tag || !signedIn) {
    return null;
  }

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
      <MenuItem onClick={openAdvancedSettings}>
        <FormattedMessage
          id='hashtags.advanced_options'
          defaultMessage='Advanced options…'
        />
      </MenuItem>
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
