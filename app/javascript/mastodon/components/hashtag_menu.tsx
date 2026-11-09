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
  return (
    <Menu>
      {children}

      <MenuList container={undefined}>
        <HashtagMenuInner tagId={tagId} accountId={accountId} />
      </MenuList>
    </Menu>
  );
};

const HashtagMenuInner: React.FC<{ tagId: string; accountId?: string }> = ({
  tagId,
  accountId,
}) => {
  const { tag, toggleFollow } = useHashtag(tagId);
  const account = useAppSelector((state) =>
    selectPlainAccount(state, accountId),
  );
  const { signedIn } = useIdentity();

  if (!tag) {
    return (
      <MenuItem disabled>
        <FormattedMessage
          id='loading_indicator.label'
          defaultMessage='Loading…'
        />
      </MenuItem>
    );
  }

  const tagName = tag.name;
  const tagNameForUrl = encodeURIComponent(tagName);

  const signedOutItems = (
    <>
      <MenuItemLink to={`/tags/${tagNameForUrl}`}>
        <FormattedMessage
          id='hashtag.browse'
          defaultMessage='Browse posts in #{hashtag}'
          values={{ hashtag: tagName }}
        />
      </MenuItemLink>
      {!!account && (
        <MenuItemLink to={`/@${account.acct}/tagged/${tagNameForUrl}`}>
          <FormattedMessage
            id='hashtag.browse_from_account'
            defaultMessage='Browse posts from @{name} in #{hashtag}'
            values={{
              name: account.username,
              hashtag: tagName,
            }}
          />
        </MenuItemLink>
      )}
    </>
  );

  if (!signedIn) {
    return signedOutItems;
  }

  return (
    <>
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

      {signedOutItems}

      <MenuItemDivider />

      <MenuItemLink as='a' href='/filters' destructive>
        <FormattedMessage
          id='hashtag.mute'
          defaultMessage='Mute #{hashtag}'
          values={{ hashtag: tagName }}
        />
      </MenuItemLink>
    </>
  );
};
