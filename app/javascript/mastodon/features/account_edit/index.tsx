import { useCallback, useEffect } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { useHistory } from 'react-router-dom';

import type { ModalType } from '@/mastodon/actions/modal';
import { openModal } from '@/mastodon/actions/modal';
import { AccountBio } from '@/mastodon/components/account_bio';
import { Avatar } from '@/mastodon/components/avatar';
import { Button } from '@/mastodon/components/button';
import { DismissibleCallout } from '@/mastodon/components/callout/dismissible';
import { CustomEmojiProvider } from '@/mastodon/components/emoji/context';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { ToggleField } from '@/mastodon/components/form_fields';
import { useElementHandledLink } from '@/mastodon/components/status/handled_link';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { autoPlayGif } from '@/mastodon/initial_state';
import {
  fetchProfile,
  patchProfile,
} from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { AccountEditColumn, AccountEditEmptyColumn } from './components/column';
import { EditButton } from './components/edit_button';
import { AccountField } from './components/field';
import { AccountFieldActions } from './components/field_actions';
import { AccountImageEdit } from './components/image_edit';
import { AccountEditSection } from './components/section';
import classes from './styles.module.scss';

export const messages = defineMessages({
  columnTitle: {
    id: 'account_edit.column_title',
    defaultMessage: 'Edit Profile',
  },
  displayNameTitle: {
    id: 'account_edit.display_name.title',
    defaultMessage: 'Display name',
  },
  displayNamePlaceholder: {
    id: 'account_edit.display_name.placeholder',
    defaultMessage:
      'Your display name is how your name appears on your profile and in timelines.',
  },
  displayNameAddLabel: {
    id: 'account_edit.display_name.add_label',
    defaultMessage: 'Add display name',
  },
  displayNameEditLabel: {
    id: 'account_edit.display_name.edit_label',
    defaultMessage: 'Edit display name',
  },
  bioTitle: {
    id: 'account_edit.bio.title',
    defaultMessage: 'Bio',
  },
  bioPlaceholder: {
    id: 'account_edit.bio.placeholder',
    defaultMessage: 'Add a short introduction to help others identify you.',
  },
  bioAddLabel: {
    id: 'account_edit.bio.add_label',
    defaultMessage: 'Add bio',
  },
  bioEditLabel: {
    id: 'account_edit.bio.edit_label',
    defaultMessage: 'Edit bio',
  },
  customFieldsTitle: {
    id: 'account_edit.custom_fields.title',
    defaultMessage: 'Custom fields',
  },
  customFieldsPlaceholder: {
    id: 'account_edit.custom_fields.placeholder',
    defaultMessage:
      'Add your pronouns, external links, or anything else you’d like to share.',
  },
  customFieldsAddLabel: {
    id: 'account_edit.custom_fields.add_label',
    defaultMessage: 'Add field',
  },
  customFieldsEditLabel: {
    id: 'account_edit.custom_fields.edit_label',
    defaultMessage: 'Edit field',
  },
  customFieldsTipTitle: {
    id: 'account_edit.custom_fields.tip_title',
    defaultMessage: 'Tip: Adding verified links',
  },
  featuredHashtagsTitle: {
    id: 'account_edit.featured_hashtags.title',
    defaultMessage: 'Featured hashtags',
  },
  featuredHashtagsPlaceholder: {
    id: 'account_edit.featured_hashtags.placeholder',
    defaultMessage:
      'Help others identify, and have quick access to, your favorite topics.',
  },
  featuredHashtagsEditLabel: {
    id: 'account_edit.featured_hashtags.edit_label',
    defaultMessage: 'Add hashtags',
  },
  profileTabTitle: {
    id: 'account_edit.profile_tab.title',
    defaultMessage: 'Profile tab settings',
  },
  profileTabSubtitle: {
    id: 'account_edit.profile_tab.subtitle',
    defaultMessage: 'Customize the tabs on your profile and what they display.',
  },
  advancedSettingsTitle: {
    id: 'account_edit.advanced_settings.title',
    defaultMessage: 'Advanced settings',
  },
});

export const AccountEdit: FC = () => {
  const accountId = useCurrentAccountId();
  const account = useAccount(accountId);
  const intl = useIntl();

  const dispatch = useAppDispatch();

  const { profile, isPending } = useAppSelector((state) => state.profileEdit);
  useEffect(() => {
    void dispatch(fetchProfile());
  }, [dispatch]);

  const maxFieldCount = useAppSelector(
    (state) =>
      (state.server.getIn([
        'server',
        'configuration',
        'accounts',
        'max_profile_fields',
      ]) as number | undefined) ?? 4,
  );

  const handleOpenModal = useCallback(
    (type: ModalType, props?: Record<string, unknown>) => {
      dispatch(openModal({ modalType: type, modalProps: props ?? {} }));
    },
    [dispatch],
  );
  const handleNameEdit = useCallback(() => {
    handleOpenModal('ACCOUNT_EDIT_NAME');
  }, [handleOpenModal]);
  const handleBioEdit = useCallback(() => {
    handleOpenModal('ACCOUNT_EDIT_BIO');
  }, [handleOpenModal]);
  const handleCustomFieldAdd = useCallback(() => {
    handleOpenModal('ACCOUNT_EDIT_FIELD_EDIT');
  }, [handleOpenModal]);
  const handleCustomFieldReorder = useCallback(() => {
    handleOpenModal('ACCOUNT_EDIT_FIELDS_REORDER');
  }, [handleOpenModal]);
  const handleCustomFieldsVerifiedHelp = useCallback(() => {
    handleOpenModal('ACCOUNT_EDIT_VERIFY_LINKS');
  }, [handleOpenModal]);
  const handleProfileDisplayEdit = useCallback(() => {
    handleOpenModal('ACCOUNT_EDIT_PROFILE_DISPLAY');
  }, [handleOpenModal]);

  const history = useHistory();
  const handleFeaturedTagsEdit = useCallback(() => {
    history.push('/profile/featured_tags');
  }, [history]);

  const handleBotToggle = useCallback(() => {
    void dispatch(patchProfile({ bot: !profile?.bot }));
  }, [dispatch, profile?.bot]);

  // Normally we would use the account emoji, but we want all custom emojis to be available to render after editing.
  const emojis = useAppSelector((state) => state.custom_emojis);
  const htmlHandlers = useElementHandledLink({
    hashtagAccountId: profile?.id,
  });

  if (!accountId || !account || !profile) {
    return <AccountEditEmptyColumn notFound={!accountId} />;
  }

  const headerSrc = autoPlayGif ? profile.header : profile.headerStatic;
  const hasName = !!profile.displayName;
  const hasBio = !!profile.bio;
  const hasFields = profile.fields.length > 0;
  const hasTags = profile.featuredTags.length > 0;

  return (
    <AccountEditColumn
      title={intl.formatMessage(messages.columnTitle)}
      to={`/@${account.acct}`}
    >
      <header>
        <div className={classes.profileImage}>
          {headerSrc && <img src={headerSrc} alt='' />}
          <AccountImageEdit location='header' />
        </div>
        <div className={classes.avatar}>
          <Avatar account={account} size={80} />
          <AccountImageEdit location='avatar' />
        </div>
      </header>

      <CustomEmojiProvider emojis={emojis}>
        <AccountEditSection
          title={messages.displayNameTitle}
          description={messages.displayNamePlaceholder}
          showDescription={!hasName}
          buttons={
            <EditButton
              onClick={handleNameEdit}
              label={intl.formatMessage(
                hasName
                  ? messages.displayNameEditLabel
                  : messages.displayNameAddLabel,
              )}
              icon={hasName}
            />
          }
        >
          <EmojiHTML htmlString={profile.displayName} {...htmlHandlers} />
        </AccountEditSection>

        <AccountEditSection
          title={messages.bioTitle}
          description={messages.bioPlaceholder}
          showDescription={!hasBio}
          buttons={
            <EditButton
              onClick={handleBioEdit}
              label={intl.formatMessage(
                hasBio ? messages.bioEditLabel : messages.bioAddLabel,
              )}
              icon={hasBio}
            />
          }
        >
          <AccountBio
            showDropdown
            accountId={profile.id}
            className={classes.bio}
          />
        </AccountEditSection>

        <AccountEditSection
          title={messages.customFieldsTitle}
          description={messages.customFieldsPlaceholder}
          showDescription={!hasFields}
          buttons={
            <div className={classes.fieldButtons}>
              {profile.fields.length > 1 && (
                <Button
                  className={classes.editButton}
                  onClick={handleCustomFieldReorder}
                >
                  <FormattedMessage
                    id='account_edit.custom_fields.reorder_button'
                    defaultMessage='Reorder fields'
                  />
                </Button>
              )}
              {profile.fields.length < maxFieldCount && (
                <EditButton
                  label={intl.formatMessage(messages.customFieldsAddLabel)}
                  onClick={handleCustomFieldAdd}
                />
              )}
            </div>
          }
        >
          {hasFields && (
            <ol>
              {profile.fields.map((field) => (
                <li key={field.id} className={classes.field}>
                  <div>
                    <AccountField {...field} {...htmlHandlers} />
                  </div>
                  <AccountFieldActions id={field.id} />
                </li>
              ))}
            </ol>
          )}
          <Button
            onClick={handleCustomFieldsVerifiedHelp}
            className={classes.verifiedLinkHelpButton}
            plain
          >
            <FormattedMessage
              id='account_edit.custom_fields.verified_hint'
              defaultMessage='How do I add a verified link?'
            />
          </Button>
          {!hasFields && (
            <DismissibleCallout
              id='profile_edit_fields_tip'
              title={intl.formatMessage(messages.customFieldsTipTitle)}
            >
              <FormattedMessage
                id='account_edit.custom_fields.tip_content'
                defaultMessage='You can easily add credibility to your Mastodon account by verifying links to any websites you own.'
              />
            </DismissibleCallout>
          )}
        </AccountEditSection>

        <AccountEditSection
          title={messages.featuredHashtagsTitle}
          description={messages.featuredHashtagsPlaceholder}
          showDescription={!hasTags}
          buttons={
            <EditButton
              onClick={handleFeaturedTagsEdit}
              icon={hasTags}
              label={intl.formatMessage(messages.featuredHashtagsEditLabel)}
            />
          }
        >
          {profile.featuredTags.map((tag) => `#${tag.name}`).join(', ')}
        </AccountEditSection>

        <AccountEditSection
          title={messages.profileTabTitle}
          description={messages.profileTabSubtitle}
          showDescription
          buttons={
            <Button
              className={classes.editButton}
              onClick={handleProfileDisplayEdit}
            >
              <FormattedMessage
                id='account_edit.profile_tab.button_label'
                defaultMessage='Customize'
              />
            </Button>
          }
        />

        <AccountEditSection title={messages.advancedSettingsTitle}>
          <ToggleField
            checked={profile.bot}
            onChange={handleBotToggle}
            disabled={isPending}
            label={
              <FormattedMessage
                id='account_edit.advanced_settings.bot_label'
                defaultMessage='Automated account'
              />
            }
            hint={
              <FormattedMessage
                id='account_edit.advanced_settings.bot_hint'
                defaultMessage='Signal to others that the account mainly performs automated actions and might not be monitored'
              />
            }
          />
        </AccountEditSection>
      </CustomEmojiProvider>
    </AccountEditColumn>
  );
};
