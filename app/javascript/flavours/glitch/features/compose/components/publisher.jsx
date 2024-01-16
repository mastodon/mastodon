import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import ImmutablePureComponent from 'react-immutable-pure-component';

import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import LockOpenIcon from '@/material-icons/400-24px/lock_open.svg?react';
import MailIcon from '@/material-icons/400-24px/mail.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import { Button } from 'flavours/glitch/components/button';
import { Icon } from 'flavours/glitch/components/icon';


const messages = defineMessages({
  publish: {
    defaultMessage: 'Publish',
    id: 'compose_form.publish',
  },
  publishLoud: {
    defaultMessage: '{publish}!',
    id: 'compose_form.publish_loud',
  },
  saveChanges: { id: 'compose_form.save_changes', defaultMessage: 'Save changes' },
  public: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted: { id: 'privacy.unlisted.short', defaultMessage: 'Unlisted' },
  private: { id: 'privacy.private.short', defaultMessage: 'Followers only' },
  direct: { id: 'privacy.direct.short', defaultMessage: 'Mentioned people only' },
});

class Publisher extends ImmutablePureComponent {

  static propTypes = {
    disabled: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    onSecondarySubmit: PropTypes.func,
    privacy: PropTypes.oneOf(['direct', 'private', 'unlisted', 'public']),
    sideArm: PropTypes.oneOf(['none', 'direct', 'private', 'unlisted', 'public']),
    isEditing: PropTypes.bool,
  };

  render () {
    const { disabled, intl, onSecondarySubmit, privacy, sideArm, isEditing } = this.props;

    const privacyIcons = {
      direct: {
        id: 'envelope',
        icon: MailIcon,
      },
      private: {
        id: 'lock',
        icon: LockIcon,
      },
      public: {
        id: 'globe',
        icon: PublicIcon,
      },
      unlisted: {
        id: 'unlock',
        icon: LockOpenIcon,
      },
    };

    let publishText;
    if (isEditing) {
      publishText = intl.formatMessage(messages.saveChanges);
    } else if (privacy === 'private' || privacy === 'direct') {
      const icon = privacyIcons[privacy];
      publishText = (
        <span>
          <Icon {...icon} /> {intl.formatMessage(messages.publish)}
        </span>
      );
    } else {
      publishText = privacy !== 'unlisted' ? intl.formatMessage(messages.publishLoud, { publish: intl.formatMessage(messages.publish) }) : intl.formatMessage(messages.publish);
    }

    const privacyNames = {
      public: messages.public,
      unlisted: messages.unlisted,
      private: messages.private,
      direct: messages.direct,
    };

    return (
      <div className='compose-form__publish'>
        {sideArm && !isEditing && sideArm !== 'none' && (
          <div className='compose-form__publish-button-wrapper'>
            <Button
              className='side_arm'
              disabled={disabled}
              onClick={onSecondarySubmit}
              style={{ padding: null }}
              text={<Icon {...privacyIcons[sideArm]} />}
              title={`${intl.formatMessage(messages.publish)}: ${intl.formatMessage(privacyNames[sideArm])}`}
            />
          </div>
        )}
        <div className='compose-form__publish-button-wrapper'>
          <Button
            className='primary'
            type='submit'
            text={publishText}
            title={`${intl.formatMessage(messages.publish)}: ${intl.formatMessage(privacyNames[privacy])}`}
            disabled={disabled}
          />
        </div>
      </div>
    );
  }

}

export default injectIntl(Publisher);
