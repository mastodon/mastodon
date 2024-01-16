import { useState, useMemo, useCallback, createRef } from 'react';

import { useIntl, defineMessages, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useHistory } from 'react-router-dom';


import { useDispatch } from 'react-redux';

import Toggle from 'react-toggle';

import AddPhotoAlternateIcon from '@/material-icons/400-24px/add_photo_alternate.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import { updateAccount } from 'flavours/glitch/actions/accounts';
import { Button } from 'flavours/glitch/components/button';
import { ColumnBackButton } from 'flavours/glitch/components/column_back_button';
import { Icon } from 'flavours/glitch/components/icon';
import { LoadingIndicator } from 'flavours/glitch/components/loading_indicator';
import { me } from 'flavours/glitch/initial_state';
import { useAppSelector } from 'flavours/glitch/store';
import { unescapeHTML } from 'flavours/glitch/utils/html';

const messages = defineMessages({
  uploadHeader: { id: 'onboarding.profile.upload_header', defaultMessage: 'Upload profile header' },
  uploadAvatar: { id: 'onboarding.profile.upload_avatar', defaultMessage: 'Upload profile picture' },
});

const nullIfMissing = path => path.endsWith('missing.png') ? null : path;

export const Profile = () => {
  const account = useAppSelector(state => state.getIn(['accounts', me]));
  const [displayName, setDisplayName] = useState(account.get('display_name'));
  const [note, setNote] = useState(unescapeHTML(account.get('note')));
  const [avatar, setAvatar] = useState(null);
  const [header, setHeader] = useState(null);
  const [discoverable, setDiscoverable] = useState(account.get('discoverable'));
  const [isSaving, setIsSaving] = useState(false);
  const [errors, setErrors] = useState();
  const avatarFileRef = createRef();
  const headerFileRef = createRef();
  const dispatch = useDispatch();
  const intl = useIntl();
  const history = useHistory();

  const handleDisplayNameChange = useCallback(e => {
    setDisplayName(e.target.value);
  }, [setDisplayName]);

  const handleNoteChange = useCallback(e => {
    setNote(e.target.value);
  }, [setNote]);

  const handleDiscoverableChange = useCallback(e => {
    setDiscoverable(e.target.checked);
  }, [setDiscoverable]);

  const handleAvatarChange = useCallback(e => {
    setAvatar(e.target?.files?.[0]);
  }, [setAvatar]);

  const handleHeaderChange = useCallback(e => {
    setHeader(e.target?.files?.[0]);
  }, [setHeader]);

  const avatarPreview = useMemo(() => avatar ? URL.createObjectURL(avatar) : nullIfMissing(account.get('avatar')), [avatar, account]);
  const headerPreview = useMemo(() => header ? URL.createObjectURL(header) : nullIfMissing(account.get('header')), [header, account]);

  const handleSubmit = useCallback(() => {
    setIsSaving(true);

    dispatch(updateAccount({
      displayName,
      note,
      avatar,
      header,
      discoverable,
      indexable: discoverable,
    })).then(() => history.push('/start/follows')).catch(err => {
      setIsSaving(false);
      setErrors(err.response.data.details);
    });
  }, [dispatch, displayName, note, avatar, header, discoverable, history]);

  return (
    <>
      <ColumnBackButton />

      <div className='scrollable privacy-policy'>
        <div className='column-title'>
          <h3><FormattedMessage id='onboarding.profile.title' defaultMessage='Profile setup' /></h3>
          <p><FormattedMessage id='onboarding.profile.lead' defaultMessage='You can always complete this later in the settings, where even more customization options are available.' /></p>
        </div>

        <div className='simple_form'>
          <div className='onboarding__profile'>
            <label className={classNames('app-form__header-input', { selected: !!headerPreview, invalid: !!errors?.header })} title={intl.formatMessage(messages.uploadHeader)}>
              <input
                type='file'
                hidden
                ref={headerFileRef}
                accept='image/*'
                onChange={handleHeaderChange}
              />

              {headerPreview && <img src={headerPreview} alt='' />}

              <Icon icon={headerPreview ? EditIcon : AddPhotoAlternateIcon} />
            </label>

            <label className={classNames('app-form__avatar-input', { selected: !!avatarPreview, invalid: !!errors?.avatar })} title={intl.formatMessage(messages.uploadAvatar)}>
              <input
                type='file'
                hidden
                ref={avatarFileRef}
                accept='image/*'
                onChange={handleAvatarChange}
              />

              {avatarPreview && <img src={avatarPreview} alt='' />}

              <Icon icon={avatarPreview ? EditIcon : AddPhotoAlternateIcon} />
            </label>
          </div>

          <div className={classNames('input with_block_label', { field_with_errors: !!errors?.display_name })}>
            <label htmlFor='display_name'><FormattedMessage id='onboarding.profile.display_name' defaultMessage='Display name' /></label>
            <span className='hint'><FormattedMessage id='onboarding.profile.display_name_hint' defaultMessage='Your full name or your fun name…' /></span>
            <div className='label_input'>
              <input id='display_name' type='text' value={displayName} onChange={handleDisplayNameChange} maxLength={30} />
            </div>
          </div>

          <div className={classNames('input with_block_label', { field_with_errors: !!errors?.note })}>
            <label htmlFor='note'><FormattedMessage id='onboarding.profile.note' defaultMessage='Bio' /></label>
            <span className='hint'><FormattedMessage id='onboarding.profile.note_hint' defaultMessage='You can @mention other people or #hashtags…' /></span>
            <div className='label_input'>
              <textarea id='note' value={note} onChange={handleNoteChange} maxLength={500} />
            </div>
          </div>

          <label className='app-form__toggle'>
            <div className='app-form__toggle__label'>
              <strong><FormattedMessage id='onboarding.profile.discoverable' defaultMessage='Make my profile discoverable' /></strong> <span className='recommended'><FormattedMessage id='recommended' defaultMessage='Recommended' /></span>
              <span className='hint'><FormattedMessage id='onboarding.profile.discoverable_hint' defaultMessage='When you opt in to discoverability on Mastodon, your posts may appear in search results and trending, and your profile may be suggested to people with similar interests to you.' /></span>
            </div>

            <div className='app-form__toggle__toggle'>
              <div>
                <Toggle checked={discoverable} onChange={handleDiscoverableChange} />
              </div>
            </div>
          </label>
        </div>

        <div className='onboarding__footer'>
          <Button block onClick={handleSubmit} disabled={isSaving}>{isSaving ? <LoadingIndicator /> : <FormattedMessage id='onboarding.profile.save_and_continue' defaultMessage='Save and continue' />}</Button>
        </div>
      </div>
    </>
  );
};
