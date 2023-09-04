import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import classNames from 'classnames';

import ImmutablePureComponent from 'react-immutable-pure-component';

import { length } from 'stringz';

import Button from 'flavours/glitch/components/button';
import { Icon } from 'flavours/glitch/components/icon';
import { maxChars } from 'flavours/glitch/initial_state';

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
    countText: PropTypes.string,
    disabled: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    onSecondarySubmit: PropTypes.func,
    onSubmit: PropTypes.func,
    privacy: PropTypes.oneOf(['direct', 'private', 'unlisted', 'public']),
    sideArm: PropTypes.oneOf(['none', 'direct', 'private', 'unlisted', 'public']),
    isEditing: PropTypes.bool,
  };

  handleSubmit = () => {
    this.props.onSubmit();
  };

  render () {
    const { countText, disabled, intl, onSecondarySubmit, privacy, sideArm, isEditing } = this.props;

    const diff = maxChars - length(countText || '');
    const computedClass = classNames('compose-form__publish', {
      disabled: disabled,
      over: diff < 0,
    });

    const privacyIcons = { direct: 'envelope', private: 'lock', public: 'globe', unlisted: 'unlock' };

    let publishText;
    if (isEditing) {
      publishText = intl.formatMessage(messages.saveChanges);
    } else if (privacy === 'private' || privacy === 'direct') {
      const iconId = privacyIcons[privacy];
      publishText = (
        <span>
          <Icon id={iconId} /> {intl.formatMessage(messages.publish)}
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
      <div className={computedClass}>
        {sideArm && !isEditing && sideArm !== 'none' ? (
          <div className='compose-form__publish-button-wrapper'>
            <Button
              className='side_arm'
              disabled={disabled}
              onClick={onSecondarySubmit}
              style={{ padding: null }}
              text={<Icon id={privacyIcons[sideArm]} />}
              title={`${intl.formatMessage(messages.publish)}: ${intl.formatMessage(privacyNames[sideArm])}`}
            />
          </div>
        ) : null}
        <div className='compose-form__publish-button-wrapper'>
          <Button
            className='primary'
            text={publishText}
            title={`${intl.formatMessage(messages.publish)}: ${intl.formatMessage(privacyNames[privacy])}`}
            onClick={this.handleSubmit}
            disabled={disabled}
          />
        </div>
      </div>
    );
  }

}

export default injectIntl(Publisher);
