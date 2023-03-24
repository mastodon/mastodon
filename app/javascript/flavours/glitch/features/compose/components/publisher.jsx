//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import { defineMessages, injectIntl } from 'react-intl';
import { length } from 'stringz';
import ImmutablePureComponent from 'react-immutable-pure-component';

//  Components.
import Button from 'flavours/glitch/components/button';
import Icon from 'flavours/glitch/components/icon';

//  Utils.
import { maxChars } from 'flavours/glitch/initial_state';

//  Messages.
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
              title={`${intl.formatMessage(messages.publish)}: ${intl.formatMessage({ id: `privacy.${sideArm}.short` })}`}
            />
          </div>
        ) : null}
        <div className='compose-form__publish-button-wrapper'>
          <Button
            className='primary'
            text={publishText}
            title={`${intl.formatMessage(messages.publish)}: ${intl.formatMessage({ id: `privacy.${privacy}.short` })}`}
            onClick={this.handleSubmit}
            disabled={disabled}
          />
        </div>
      </div>
    );
  }

}

export default injectIntl(Publisher);
