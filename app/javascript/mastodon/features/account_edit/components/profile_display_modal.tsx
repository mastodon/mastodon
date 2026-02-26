import type { FC } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { Toggle } from '@/mastodon/components/form_fields';

import type { DialogModalProps } from '../../ui/components/dialog_modal';
import { DialogModal } from '../../ui/components/dialog_modal';
import { messages } from '../index';
import classes from '../styles.module.scss';

export const ProfileDisplayModal: FC<DialogModalProps> = ({ onClose }) => {
  const intl = useIntl();
  return (
    <DialogModal
      onClose={onClose}
      title={intl.formatMessage(messages.profileTabTitle)}
      noCancelButton
      formClassName={classes.formOverride}
    >
      <div className={classes.toggleInputWrapper}>
        <FormattedMessage
          id='account_edit.profile_tab.show_media.title'
          defaultMessage='Show ‘Media’ tab'
          tagName='h2'
        />
        <FormattedMessage
          id='account_edit.profile_tab.show_media.description'
          defaultMessage='‘Media’ is an optional tab that shows your posts containing images or videos.'
          tagName='h3'
        />
        <Toggle />
      </div>
      <div className={classes.toggleInputWrapper}>
        <FormattedMessage
          id='account_edit.profile_tab.show_media_replies.title'
          defaultMessage='Include replies on ‘Media’ tab'
          tagName='h2'
        />
        <FormattedMessage
          id='account_edit.profile_tab.show_media_replies.description'
          defaultMessage='When enabled, Media tab shows both your posts and replies to other people’s posts.'
          tagName='h3'
        />
        <Toggle />
      </div>
      <div className={classes.toggleInputWrapper}>
        <FormattedMessage
          id='account_edit.profile_tab.show_featured.title'
          defaultMessage='Show ‘Featured’ tab'
          tagName='h2'
        />
        <FormattedMessage
          id='account_edit.profile_tab.show_featured.description'
          defaultMessage='‘Featured’ is an optional tab where you can showcase other accounts.'
          tagName='h3'
        />
        <Toggle />
      </div>
    </DialogModal>
  );
};
