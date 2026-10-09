import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  MarkdownLogoIcon,
  EyeSlashIcon,
  GearIcon,
  WarningIcon,
} from '@phosphor-icons/react';

import {
  changeComposeSensitivity,
  changeComposeSpoilerness,
 changeComposeContentType } from '@/flavours/glitch/actions/compose';
import { setComposeQuotePolicy } from '@/flavours/glitch/actions/compose_typed';
import type { ApiQuotePolicy } from '@/flavours/glitch/api_types/quotes';
import { IconButton } from '@/flavours/glitch/components/button/redesign';
import {
  Menu,
  MenuItemCheckbox,
  MenuItemDivider,
  MenuItemGroup,
  MenuItemRadio,
  MenuList,
  MenuTrigger,
} from '@/flavours/glitch/components/menu';
import {
  useAppDispatch,
  useAppSelector,
} from '@/flavours/glitch/store/typed_functions';

import {
  selectComposePrivacy,
  selectComposeQuotePolicy,
  selectComposeSensitive,
} from './selectors';

export const ComposeSettingsMenu: React.FC = () => {
  return (
    <Menu>
      <MenuTrigger as={IconButton} icon={GearIcon} size='sm'>
        <FormattedMessage id='compose.settings' defaultMessage='Settings' />
      </MenuTrigger>

      <MenuList maxWidth={280} placement='top-end' strategy='fixed'>
        <ComposeSettingsInnerMenu />
      </MenuList>
    </Menu>
  );
};

const ComposeSettingsInnerMenu: React.FC = () => {
  // Quote policy
  const quotePolicy = useAppSelector(selectComposeQuotePolicy);
  const privacy = useAppSelector(selectComposePrivacy);
  const disablePublicQuotes = privacy === 'private';

  const dispatch = useAppDispatch();
  const onQuotePolicyChange = useCallback(
    ({ value }: { value: string }) => {
      let newQuotePolicy: ApiQuotePolicy = 'nobody';
      switch (value) {
        case 'public':
          newQuotePolicy = 'public';
          break;
        case 'followers':
          newQuotePolicy = 'followers';
          break;
      }
      dispatch(setComposeQuotePolicy(newQuotePolicy));
    },
    [dispatch],
  );

  // Sensitive content
  const { sensitive, mediaSensitive } = useAppSelector(selectComposeSensitive);

  const onSensitiveChange = useCallback(() => {
    dispatch(changeComposeSpoilerness());
  }, [dispatch]);
  const onMediaSensitiveChange = useCallback(() => {
    dispatch(changeComposeSensitivity());
  }, [dispatch]);

  // glitch-soc additions
  const contentType = useAppSelector((state) =>
    state.compose.get('content_type'),
  );
  const onMarkdownChange = useCallback(() => {
    dispatch(
      changeComposeContentType(
        contentType === 'text/plain' ? 'text/markdown' : 'text/plain',
      ),
    );
  }, [contentType, dispatch]);

  return (
    <>
      {privacy !== 'direct' && (
        <MenuItemGroup
          label={
            <FormattedMessage
              id='compose.visibility.quote_policy'
              defaultMessage='Who can quote'
            />
          }
        >
          <MenuItemRadio
            name='quote_policy'
            value='public'
            checked={quotePolicy === 'public'}
            onChange={onQuotePolicyChange}
            disabled={disablePublicQuotes}
            keepMenuOpenOnClick
          >
            <FormattedMessage
              id='visibility_modal.quote_public'
              defaultMessage='Anyone'
            />
          </MenuItemRadio>

          <MenuItemRadio
            name='quote_policy'
            value='followers'
            checked={quotePolicy === 'followers'}
            onChange={onQuotePolicyChange}
            disabled={disablePublicQuotes}
            keepMenuOpenOnClick
          >
            <FormattedMessage
              id='compose.visibility.quote_policy.followers'
              defaultMessage='Followers'
            />
          </MenuItemRadio>

          <MenuItemRadio
            name='quote_policy'
            value='nobody'
            checked={quotePolicy === 'nobody'}
            onChange={onQuotePolicyChange}
            description={
              disablePublicQuotes && (
                <FormattedMessage
                  id='compose.visibility.quote_policy.only_me_hint'
                  defaultMessage="When your post's visibility is set to Followers, it can only be quoted by you."
                />
              )
            }
            keepMenuOpenOnClick
          >
            <FormattedMessage
              id='visibility_modal.quote_nobody'
              defaultMessage='Just me'
            />
          </MenuItemRadio>
        </MenuItemGroup>
      )}

      {privacy !== 'direct' && <MenuItemDivider />}

      <MenuItemGroup
        label={
          <FormattedMessage
            id='compose.sensitive.label'
            defaultMessage='Sensitive content'
          />
        }
      >
        <MenuItemCheckbox
          name='content_warning'
          value='on'
          checked={sensitive}
          onChange={onSensitiveChange}
          keepMenuOpenOnClick
          icon={WarningIcon}
        >
          <FormattedMessage
            id='compose_form.spoiler.unmarked'
            defaultMessage='Add content warning'
          />
        </MenuItemCheckbox>
        <MenuItemCheckbox
          name='media_spoiler'
          value='on'
          checked={mediaSensitive}
          disabled={sensitive}
          onChange={onMediaSensitiveChange}
          keepMenuOpenOnClick
          icon={EyeSlashIcon}
        >
          <FormattedMessage
            id='compose.blur_media'
            defaultMessage='Blur media'
          />
        </MenuItemCheckbox>
      </MenuItemGroup>

      <MenuItemDivider />

      <MenuItemGroup
        label={
          <FormattedMessage
            id='compose.glitch_settings.label'
            defaultMessage='glitch-soc settings'
          />
        }
      >
        <MenuItemCheckbox
          name='markdown_formatting'
          value='on'
          checked={contentType === 'text/markdown'}
          onChange={onMarkdownChange}
          keepMenuOpenOnClick
          icon={MarkdownLogoIcon}
        >
          <FormattedMessage
            id='compose.glitch.use_markdown'
            defaultMessage='Use Markdown formatting'
          />
        </MenuItemCheckbox>
      </MenuItemGroup>
    </>
  );
};
