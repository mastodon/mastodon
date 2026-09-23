import { FormattedMessage } from 'react-intl';

import { useHashtag } from '@/mastodon/hooks/useHashtag';
import { useIdentity } from '@/mastodon/identity_context';

import { selectPlainAccount } from '../selectors/accounts';
import { useAppSelector } from '../store';

import {
  Menu,
  MenuItem,
  MenuItemDivider,
  MenuItemLink,
  MenuList,
} from './menu';

export const HashtagMenu: React.FC<{
  tagId: string;
  accountId?: string;
  children?: React.ReactNode;
}> = ({ tagId, accountId, children }) => {
  const { tag, toggleFollow } = useHashtag(tagId);
  const account = useAppSelector((state) =>
    selectPlainAccount(state, accountId),
  );
  const { signedIn } = useIdentity();

  if (!tag) {
    return null;
  }

  return (
    <Menu>
      {children}

      <MenuList container={undefined}>
        {signedIn && (
          <MenuItem onClick={toggleFollow}>
            {tag.following ? (
              <FormattedMessage
                id='hashtag.unfollow'
                defaultMessage='Unfollow hashtag'
              />
            ) : (
              <FormattedMessage
                id='hashtag.follow'
                defaultMessage='Follow hashtag'
              />
            )}
          </MenuItem>
        )}
        <MenuItemLink to={`/tags/${encodeURIComponent(tag.name)}`}>
          <FormattedMessage
            id='hashtag.browse'
            defaultMessage='Browse posts in #{hashtag}'
            values={{ hashtag: tag.name }}
          />
        </MenuItemLink>
        {!!account && (
          <MenuItemLink
            to={`/@${account.acct}/tagged/${encodeURIComponent(tag.name)}`}
          >
            <FormattedMessage
              id='hashtag.browse_from_account'
              defaultMessage='Browse posts from @{name} in #{hashtag}'
              values={{
                name: account.username,
                hashtag: tag.name,
              }}
            />
          </MenuItemLink>
        )}
        {signedIn && (
          <>
            <MenuItemDivider />
            <MenuItemLink as='a' href='/filters' destructive>
              <FormattedMessage
                id='hashtag.mute'
                defaultMessage='Mute #{hashtag}'
                values={{ hashtag: tag.name }}
              />
            </MenuItemLink>
          </>
        )}
      </MenuList>
    </Menu>
  );
};
