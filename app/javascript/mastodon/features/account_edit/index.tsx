import { useCallback } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Link } from 'react-router-dom';

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
import { useAppDispatch } from '@/mastodon/store';

import { AccountEditSection } from './components/section';
import classes from './styles.module.scss';

const messages = defineMessages({
  displayNameTitle: {
    id: 'account_edit.display_name.title',
    defaultMessage: 'Display name',
  },
  bioTitle: {
    id: 'account_edit.bio.title',
    defaultMessage: 'Bio',
  },
  customFieldsTitle: {
    id: 'account_edit.custom_fields.title',
    defaultMessage: 'Custom fields',
  },
  featuredHashtagsTitle: {
    id: 'account_edit.featured_hashtags.title',
    defaultMessage: 'Featured hashtags',
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
        onEdit={handleNameEdit}
      >
        <DisplayNameSimple account={account} />
      </AccountEditSection>

      <AccountEditSection title={messages.bioTitle} onEdit={handleBioEdit}>
        <AccountBio accountId={accountId} />
      </AccountEditSection>

      <AccountEditSection title={messages.customFieldsTitle}>
        <p>fields here</p>
      </AccountEditSection>

      <AccountEditSection title={messages.featuredHashtagsTitle}>
        <p>featured tags here</p>
      </AccountEditSection>

      <AccountEditSection
        title={messages.profileTabTitle}
        subtitle={messages.profileTabSubtitle}
      >
        <p>tab settings here</p>
      </AccountEditSection>
    </Column>
  );
};
