import { useCallback, useEffect } from 'react';
import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { useHistory } from 'react-router-dom';

import type { ModalType } from '@/mastodon/actions/modal';
import { openModal } from '@/mastodon/actions/modal';
import { AccountBio } from '@/mastodon/components/account_bio';
import { Avatar } from '@/mastodon/components/avatar';
import { DisplayNameSimple } from '@/mastodon/components/display_name/simple';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { autoPlayGif } from '@/mastodon/initial_state';
import { fetchFeaturedTags } from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { AccountEditColumn, AccountEditEmptyColumn } from './components/column';
import { EditButton } from './components/edit_button';
import { AccountEditSection } from './components/section';
import classes from './styles.module.scss';

const messages = defineMessages({
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
  bioTitle: {
    id: 'account_edit.bio.title',
    defaultMessage: 'Bio',
  },
  bioPlaceholder: {
    id: 'account_edit.bio.placeholder',
    defaultMessage: 'Add a short introduction to help others identify you.',
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
  featuredHashtagsTitle: {
    id: 'account_edit.featured_hashtags.title',
    defaultMessage: 'Featured hashtags',
  },
  featuredHashtagsPlaceholder: {
    id: 'account_edit.featured_hashtags.placeholder',
    defaultMessage:
      'Help others identify, and have quick access to, your favorite topics.',
  },
  featuredHashtagsItem: {
    id: 'account_edit.featured_hashtags.item',
    defaultMessage: 'hashtags',
  },
  profileTabTitle: {
    id: 'account_edit.profile_tab.title',
    defaultMessage: 'Profile tab settings',
  },
  profileTabSubtitle: {
    id: 'account_edit.profile_tab.subtitle',
    defaultMessage: 'Customize the tabs on your profile and what they display.',
  },
});

export const AccountEdit: FC = () => {
  const accountId = useCurrentAccountId();
  const account = useAccount(accountId);
  const intl = useIntl();

  const dispatch = useAppDispatch();

  const { tags: featuredTags, isLoading: isTagsLoading } = useAppSelector(
    (state) => state.profileEdit,
  );
  useEffect(() => {
    void dispatch(fetchFeaturedTags());
  }, [dispatch]);

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

  const history = useHistory();
  const handleFeaturedTagsEdit = useCallback(() => {
    history.push('/profile/featured_tags');
  }, [history]);

  if (!accountId || !account) {
    return <AccountEditEmptyColumn notFound={!accountId} />;
  }

  const headerSrc = autoPlayGif ? account.header : account.header_static;
  const hasName = !!account.display_name;
  const hasBio = !!account.note_plain;
  const hasTags = !isTagsLoading && featuredTags.length > 0;

  return (
    <AccountEditColumn
      title={intl.formatMessage(messages.columnTitle)}
      to={`/@${account.acct}`}
    >
      <header>
        <div className={classes.profileImage}>
          {headerSrc && <img src={headerSrc} alt='' />}
        </div>
        <Avatar account={account} size={80} className={classes.avatar} />
      </header>

      <AccountEditSection
        title={messages.displayNameTitle}
        description={messages.displayNamePlaceholder}
        showDescription={!hasName}
        buttons={
          <EditButton
            onClick={handleNameEdit}
            item={messages.displayNameTitle}
            edit={hasName}
          />
        }
      >
        <DisplayNameSimple account={account} />
      </AccountEditSection>

      <AccountEditSection
        title={messages.bioTitle}
        description={messages.bioPlaceholder}
        showDescription={!hasBio}
        buttons={
          <EditButton
            onClick={handleBioEdit}
            item={messages.bioTitle}
            edit={hasBio}
          />
        }
      >
        <AccountBio accountId={accountId} />
      </AccountEditSection>

      <AccountEditSection
        title={messages.customFieldsTitle}
        description={messages.customFieldsPlaceholder}
        showDescription
      />

      <AccountEditSection
        title={messages.featuredHashtagsTitle}
        description={messages.featuredHashtagsPlaceholder}
        showDescription={!hasTags}
        buttons={
          <EditButton
            onClick={handleFeaturedTagsEdit}
            edit={hasTags}
            item={messages.featuredHashtagsItem}
          />
        }
      >
        {featuredTags.map((tag) => `#${tag.name}`).join(', ')}
      </AccountEditSection>

      <AccountEditSection
        title={messages.profileTabTitle}
        description={messages.profileTabSubtitle}
        showDescription
      />
    </AccountEditColumn>
  );
};
