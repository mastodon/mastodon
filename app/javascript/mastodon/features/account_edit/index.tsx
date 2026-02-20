import { useCallback, useEffect } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Link, useHistory } from 'react-router-dom';

import { fetchFeaturedTags } from '@/mastodon/actions/featured_tags';
import type { ModalType } from '@/mastodon/actions/modal';
import { openModal } from '@/mastodon/actions/modal';
import { AccountBio } from '@/mastodon/components/account_bio';
import { Avatar } from '@/mastodon/components/avatar';
import { Column } from '@/mastodon/components/column';
import { ColumnHeader } from '@/mastodon/components/column_header';
import { DisplayNameSimple } from '@/mastodon/components/display_name/simple';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { autoPlayGif } from '@/mastodon/initial_state';
import { selectAccountFeaturedTags } from '@/mastodon/selectors/accounts';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { EditButton } from './components/edit_button';
import { AccountEditSection } from './components/section';
import classes from './styles.module.scss';

const messages = defineMessages({
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

export const AccountEdit: FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const accountId = useCurrentAccountId();
  const account = useAccount(accountId);
  const intl = useIntl();

  const dispatch = useAppDispatch();

  useEffect(() => {
    if (accountId) {
      void dispatch(fetchFeaturedTags({ accountId }));
    }
  }, [accountId, dispatch]);
  const featuredTags = useAppSelector((state) =>
    accountId ? selectAccountFeaturedTags(state, accountId) : null,
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

  const history = useHistory();
  const handleFeaturedTagsEdit = useCallback(() => {
    history.push('/profile/featured_tags');
  }, [history]);

  if (!accountId) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  if (!account) {
    return (
      <Column bindToDocument={!multiColumn} className={classes.column}>
        <LoadingIndicator />
      </Column>
    );
  }

  const headerSrc = autoPlayGif ? account.header : account.header_static;
  const hasName = !!account.display_name;
  const hasBio = !!account.note_plain;
  const hasTags = Array.isArray(featuredTags);

  return (
    <Column bindToDocument={!multiColumn} className={classes.column}>
      <ColumnHeader
        title={intl.formatMessage({
          id: 'account_edit.column_title',
          defaultMessage: 'Edit Profile',
        })}
        className={classes.columnHeader}
        showBackButton
        extraButton={
          <Link to={`/@${account.acct}`} className='button'>
            <FormattedMessage
              id='account_edit.column_button'
              defaultMessage='Done'
            />
          </Link>
        }
      />
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
        {featuredTags?.map((tag) => `#${tag.name}`).join(', ')}
      </AccountEditSection>

      <AccountEditSection
        title={messages.profileTabTitle}
        description={messages.profileTabSubtitle}
        showDescription
      />
    </Column>
  );
};
