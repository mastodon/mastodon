import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { ChatCircleDotsIcon, NewspaperIcon } from '@phosphor-icons/react';

import { changeComposeVisibility } from '@/mastodon/actions/compose_typed';
import { openModal } from '@/mastodon/actions/modal';
import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import { Button, CaretIcon } from '@/mastodon/components/button/redesign';
import {
  Menu,
  MenuList,
  MenuTrigger,
  MenuItemDivider,
  MenuItemGroup,
  MenuItem,
  MenuItemRadio,
  MenuItemCheckbox,
} from '@/mastodon/components/menu';
import { Tooltip } from '@/mastodon/components/tooltip';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { selectComposePrivacy } from './selectors';

export const ComposeVisibility: React.FC<{ className?: string }> = ({
  className,
}) => {
  const privacy = useAppSelector(selectComposePrivacy);
  const isEditing = useAppSelector((state) => !!state.compose.get('id'));

  if (isEditing) {
    return (
      <div className={className}>
        <Tooltip
          renderTextWhenClosed
          text={
            <FormattedMessage
              id='compose.privacy.editing'
              defaultMessage='Visibility can’t be edited after a post has been published.'
            />
          }
        >
          {({ getTooltipProps, tooltipId }) => (
            <Button
              {...getTooltipProps()}
              size='sm'
              aria-disabled
              aria-describedby={tooltipId}
            >
              <ComposeVisibilityButtonText privacy={privacy} />
            </Button>
          )}
        </Tooltip>
      </div>
    );
  }

  return (
    <div className={className}>
      <Menu>
        <MenuTrigger as={Button} size='sm' trailingIcon={CaretIcon}>
          <ComposeVisibilityButtonText privacy={privacy} />
        </MenuTrigger>

        {privacy !== 'direct' ? (
          <ComposeVisibilityMenu />
        ) : (
          <ComposeDirectMenu />
        )}
      </Menu>
    </div>
  );
};

const ComposeVisibilityButtonText: React.FC<{
  privacy: StatusVisibility;
}> = ({ privacy }) => {
  if (privacy === 'public') {
    return (
      <FormattedMessage id='privacy.public.short' defaultMessage='Public' />
    );
  } else if (privacy === 'unlisted') {
    return (
      <FormattedMessage
        id='compose.privacy.unlisted'
        defaultMessage='Public, hidden from search'
      />
    );
  } else if (privacy === 'private') {
    return (
      <FormattedMessage
        id='compose.privacy.followers'
        defaultMessage='Followers (+ mentions)'
      />
    );
  }

  return '-';
};

const ComposeVisibilityMenu: React.FC = () => {
  const privacy = useAppSelector(selectComposePrivacy);
  const defaultPrivacy = useAppSelector(
    (state) => state.compose.get('default_privacy') as StatusVisibility,
  );

  const isReply = useAppSelector((state) => !!state.compose.get('in_reply_to'));

  const dispatch = useAppDispatch();
  const handlePrivacyChange = useCallback(
    ({ value }: { value: string }) => {
      if (value === 'private' && privacy !== 'private') {
        dispatch(changeComposeVisibility(value));
      } else if (value === 'public' && privacy === 'private') {
        dispatch(
          changeComposeVisibility(
            defaultPrivacy === 'unlisted' ? 'unlisted' : 'public',
          ),
        );
      } else if (value === 'unlisted' && privacy !== 'private') {
        dispatch(
          changeComposeVisibility(privacy === 'public' ? 'unlisted' : 'public'),
        );
      }
    },
    [defaultPrivacy, dispatch, privacy],
  );

  const handleSwitchToMessage: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(() => {
      dispatch(changeComposeVisibility('direct'));
    }, [dispatch]);

  return (
    <MenuList placement='bottom-start' offset={4} maxWidth={280}>
      <MenuItemGroup
        label={
          <FormattedMessage
            id='compose.visibility.title'
            defaultMessage='Visibility'
          />
        }
      >
        <MenuItemRadio
          name='visibility'
          value='public'
          checked={privacy === 'public' || privacy === 'unlisted'}
          onChange={handlePrivacyChange}
          keepMenuOpenOnClick
        >
          <FormattedMessage id='privacy.public.short' defaultMessage='Public' />
        </MenuItemRadio>

        <MenuItemRadio
          name='visibility'
          value='private'
          checked={privacy === 'private'}
          onChange={handlePrivacyChange}
          keepMenuOpenOnClick
        >
          <FormattedMessage
            id='compose.privacy.followers'
            defaultMessage='Followers (+ mentions)'
          />
        </MenuItemRadio>

        <MenuItemDivider />

        <MenuItemCheckbox
          value='unlisted'
          disabled={privacy === 'private'}
          checked={privacy === 'unlisted' || privacy === 'private'}
          onChange={handlePrivacyChange}
          keepMenuOpenOnClick
          description={
            <FormattedMessage
              id='compose.discoverable.hint'
              defaultMessage='Also applies to discovery feeds'
            />
          }
        >
          <FormattedMessage
            id='compose.discoverable'
            defaultMessage='Hide from search results'
          />
        </MenuItemCheckbox>
      </MenuItemGroup>

      <MenuItemDivider />

      <MenuItem icon={ChatCircleDotsIcon} onClick={handleSwitchToMessage}>
        {isReply ? (
          <FormattedMessage
            id='compose.post.to_private_reply'
            defaultMessage='Reply privately instead'
          />
        ) : (
          <FormattedMessage
            id='compose.post.to_message'
            defaultMessage='Convert to private message'
            description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
          />
        )}
      </MenuItem>
    </MenuList>
  );
};

const ComposeDirectMenu: React.FC = () => {
  const dispatch = useAppDispatch();
  const handleSwitchToPost: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(() => {
      dispatch(
        openModal({ modalType: 'COMPOSER_SWITCH_TO_POST', modalProps: {} }),
      );
    }, [dispatch]);

  const isReply = useAppSelector((state) => !!state.compose.get('in_reply_to'));

  return (
    <MenuList placement='bottom-start' offset={4} maxWidth={280}>
      <MenuItemGroup
        label={
          <FormattedMessage
            id='compose.visibility.title'
            defaultMessage='Visibility'
          />
        }
      >
        <MenuItemRadio value='direct' disabled checked>
          <FormattedMessage
            id='compose.visibility.direct_note'
            defaultMessage='Everyone mentioned'
          />
        </MenuItemRadio>
      </MenuItemGroup>

      <MenuItemDivider />

      <MenuItem icon={NewspaperIcon} onClick={handleSwitchToPost}>
        {isReply ? (
          <FormattedMessage
            id='compose.visibility.to_reply'
            defaultMessage='Reply publicly instead'
          />
        ) : (
          <FormattedMessage
            id='compose.visibility.to_post'
            defaultMessage='Compose a post instead'
          />
        )}
      </MenuItem>
    </MenuList>
  );
};
