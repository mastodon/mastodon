import type { ChangeEventHandler, FC } from 'react';
import { useCallback } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { Callout } from '@/mastodon/components/callout';
import { ToggleField } from '@/mastodon/components/form_fields';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { patchProfile } from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import type { DialogModalProps } from '../../ui/components/dialog_modal';
import { DialogModal } from '../../ui/components/dialog_modal';
import { messages } from '../index';
import classes from '../styles.module.scss';

export const ProfileDisplayModal: FC<DialogModalProps> = ({ onClose }) => {
  const intl = useIntl();

  const { profile, isPending } = useAppSelector((state) => state.profileEdit);
  const serverName = useAppSelector(
    (state) => state.meta.get('domain') as string,
  );

  const dispatch = useAppDispatch();
  const handleToggleChange: ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      const { name, checked } = event.target;
      void dispatch(patchProfile({ [name]: checked }));
    },
    [dispatch],
  );

  if (!profile) {
    return <LoadingIndicator />;
  }

  return (
    <DialogModal
      onClose={onClose}
      title={intl.formatMessage(messages.profileTabTitle)}
      noCancelButton
    >
      <div className={classes.toggleInputWrapper}>
        <ToggleField
          checked={profile.showMedia}
          onChange={handleToggleChange}
          disabled={isPending}
          name='show_media'
          label={
            <FormattedMessage
              id='account_edit.profile_tab.show_media.title'
              defaultMessage='Show ‘Media’ tab'
            />
          }
          hint={
            <FormattedMessage
              id='account_edit.profile_tab.show_media.description'
              defaultMessage='‘Media’ is an optional tab that shows your posts containing images or videos.'
            />
          }
        />

        <ToggleField
          checked={profile.showMediaReplies}
          onChange={handleToggleChange}
          disabled={!profile.showMedia || isPending}
          name='show_media_replies'
          label={
            <FormattedMessage
              id='account_edit.profile_tab.show_media_replies.title'
              defaultMessage='Include replies on ‘Media’ tab'
            />
          }
          hint={
            <FormattedMessage
              id='account_edit.profile_tab.show_media_replies.description'
              defaultMessage='When enabled, Media tab shows both your posts and replies to other people’s posts.'
            />
          }
        />

        <ToggleField
          checked={profile.showFeatured}
          onChange={handleToggleChange}
          disabled={isPending}
          name='show_featured'
          label={
            <FormattedMessage
              id='account_edit.profile_tab.show_featured.title'
              defaultMessage='Show ‘Featured’ tab'
            />
          }
          hint={
            <FormattedMessage
              id='account_edit.profile_tab.show_featured.description'
              defaultMessage='‘Featured’ is an optional tab where you can showcase other accounts.'
            />
          }
        />
      </div>

      <Callout
        title={
          <FormattedMessage
            id='account_edit.profile_tab.hint.title'
            defaultMessage='Displays still vary'
          />
        }
        icon={false}
      >
        <FormattedMessage
          id='account_edit.profile_tab.hint.description'
          defaultMessage='These settings customize what users see on {server} in the official apps, but they may not apply to users on other servers and 3rd party apps.'
          values={{
            server: serverName,
          }}
        />
      </Callout>
    </DialogModal>
  );
};
