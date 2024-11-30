import { useState, useMemo, useCallback, createRef } from 'react';

import { useIntl, defineMessages, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Helmet } from 'react-helmet';
import { useHistory } from 'react-router-dom';

import Toggle from 'react-toggle';

import AddPhotoAlternateIcon from '@/material-icons/400-24px/add_photo_alternate.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import PersonIcon from '@/material-icons/400-24px/person.svg?react';
import { updateAccount } from 'mastodon/actions/accounts';
import { Button } from 'mastodon/components/button';
import Column from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { Icon } from 'mastodon/components/icon';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { me } from 'mastodon/initial_state';
import { useAppSelector, useAppDispatch } from 'mastodon/store';
import { unescapeHTML } from 'mastodon/utils/html';

const messages = defineMessages({
  title: {
    id: 'onboarding.profile.title',
    defaultMessage: 'Profile setup',
  },
  uploadHeader: {
    id: 'onboarding.profile.upload_header',
    defaultMessage: 'Upload profile header',
  },
  uploadAvatar: {
    id: 'onboarding.profile.upload_avatar',
    defaultMessage: 'Upload profile picture',
  },
});

const nullIfMissing = (path: string) =>
  path.endsWith('missing.png') ? null : path;

interface ApiAccountErrors {
  display_name?: unknown;
  note?: unknown;
  avatar?: unknown;
  header?: unknown;
}

export const Profile: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const account = useAppSelector((state) =>
    me ? state.accounts.get(me) : undefined,
  );
  const [displayName, setDisplayName] = useState(account?.display_name ?? '');
  const [note, setNote] = useState(
    account ? (unescapeHTML(account.note) ?? '') : '',
  );
  const [avatar, setAvatar] = useState<File>();
  const [header, setHeader] = useState<File>();
  const [discoverable, setDiscoverable] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [errors, setErrors] = useState<ApiAccountErrors>();
  const avatarFileRef = createRef<HTMLInputElement>();
  const headerFileRef = createRef<HTMLInputElement>();
  const dispatch = useAppDispatch();
  const intl = useIntl();
  const history = useHistory();

  const handleDisplayNameChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      setDisplayName(e.target.value);
    },
    [setDisplayName],
  );

  const handleNoteChange = useCallback(
    (e: React.ChangeEvent<HTMLTextAreaElement>) => {
      setNote(e.target.value);
    },
    [setNote],
  );

  const handleDiscoverableChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      setDiscoverable(e.target.checked);
    },
    [setDiscoverable],
  );

  const handleAvatarChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      setAvatar(e.target.files?.[0]);
    },
    [setAvatar],
  );

  const handleHeaderChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      setHeader(e.target.files?.[0]);
    },
    [setHeader],
  );

  const avatarPreview = useMemo(
    () =>
      avatar
        ? URL.createObjectURL(avatar)
        : nullIfMissing(account?.avatar ?? 'missing.png'),
    [avatar, account],
  );
  const headerPreview = useMemo(
    () =>
      header
        ? URL.createObjectURL(header)
        : nullIfMissing(account?.header ?? 'missing.png'),
    [header, account],
  );

  const handleSubmit = useCallback(() => {
    setIsSaving(true);

    dispatch(
      updateAccount({
        displayName,
        note,
        avatar,
        header,
        discoverable,
        indexable: discoverable,
      }),
    )
      .then(() => {
        history.push('/start/follows');
        return '';
      })
      // eslint-disable-next-line @typescript-eslint/use-unknown-in-catch-callback-variable
      .catch((err) => {
        // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
        if (err.response) {
          // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
          const { details }: { details: ApiAccountErrors } = err.response.data;
          setErrors(details);
        }

        setIsSaving(false);
      });
  }, [dispatch, displayName, note, avatar, header, discoverable, history]);

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(messages.title)}
    >
      <ColumnHeader
        title={intl.formatMessage(messages.title)}
        icon='person'
        iconComponent={PersonIcon}
        multiColumn={multiColumn}
      />

      <div className='scrollable scrollable--flex'>
        <div className='simple_form app-form'>
          <div className='onboarding__profile'>
            <label
              className={classNames('app-form__header-input', {
                selected: !!headerPreview,
                invalid: !!errors?.header,
              })}
              title={intl.formatMessage(messages.uploadHeader)}
            >
              <input
                type='file'
                hidden
                ref={headerFileRef}
                accept='image/*'
                onChange={handleHeaderChange}
              />

              {headerPreview && <img src={headerPreview} alt='' />}

              <Icon
                id=''
                icon={headerPreview ? EditIcon : AddPhotoAlternateIcon}
              />
            </label>

            <label
              className={classNames('app-form__avatar-input', {
                selected: !!avatarPreview,
                invalid: !!errors?.avatar,
              })}
              title={intl.formatMessage(messages.uploadAvatar)}
            >
              <input
                type='file'
                hidden
                ref={avatarFileRef}
                accept='image/*'
                onChange={handleAvatarChange}
              />

              {avatarPreview && <img src={avatarPreview} alt='' />}

              <Icon
                id=''
                icon={avatarPreview ? EditIcon : AddPhotoAlternateIcon}
              />
            </label>
          </div>

          <div className='fields-group'>
            <div
              className={classNames('input with_block_label', {
                field_with_errors: !!errors?.display_name,
              })}
            >
              <label htmlFor='display_name'>
                <FormattedMessage
                  id='onboarding.profile.display_name'
                  defaultMessage='Display name'
                />
              </label>
              <span className='hint'>
                <FormattedMessage
                  id='onboarding.profile.display_name_hint'
                  defaultMessage='Your full name or your fun name…'
                />
              </span>
              <div className='label_input'>
                <input
                  id='display_name'
                  type='text'
                  value={displayName}
                  onChange={handleDisplayNameChange}
                  maxLength={30}
                />
              </div>
            </div>
          </div>

          <div className='fields-group'>
            <div
              className={classNames('input with_block_label', {
                field_with_errors: !!errors?.note,
              })}
            >
              <label htmlFor='note'>
                <FormattedMessage
                  id='onboarding.profile.note'
                  defaultMessage='Bio'
                />
              </label>
              <span className='hint'>
                <FormattedMessage
                  id='onboarding.profile.note_hint'
                  defaultMessage='You can @mention other people or #hashtags…'
                />
              </span>
              <div className='label_input'>
                <textarea
                  id='note'
                  value={note}
                  onChange={handleNoteChange}
                  maxLength={500}
                />
              </div>
            </div>
          </div>

          <label className='app-form__toggle'>
            <div className='app-form__toggle__label'>
              <strong>
                <FormattedMessage
                  id='onboarding.profile.discoverable'
                  defaultMessage='Make my profile discoverable'
                />
              </strong>{' '}
              <span className='recommended'>
                <FormattedMessage
                  id='recommended'
                  defaultMessage='Recommended'
                />
              </span>
              <span className='hint'>
                <FormattedMessage
                  id='onboarding.profile.discoverable_hint'
                  defaultMessage='When you opt in to discoverability on Mastodon, your posts may appear in search results and trending, and your profile may be suggested to people with similar interests to you.'
                />
              </span>
            </div>

            <div className='app-form__toggle__toggle'>
              <div>
                <Toggle
                  checked={discoverable}
                  onChange={handleDiscoverableChange}
                />
              </div>
            </div>
          </label>
        </div>

        <div className='spacer' />

        <div className='column-footer'>
          <Button block onClick={handleSubmit} disabled={isSaving}>
            {isSaving ? (
              <LoadingIndicator />
            ) : (
              <FormattedMessage
                id='onboarding.profile.save_and_continue'
                defaultMessage='Save and continue'
              />
            )}
          </Button>
        </div>
      </div>

      <Helmet>
        <title>{intl.formatMessage(messages.title)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Profile;
