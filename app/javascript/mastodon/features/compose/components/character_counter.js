import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import { length } from 'stringz';

const messages = defineMessages({
  remaining: { id: 'character_counter.remaining', defaultMessage: 'character remaining' },
  remaining_plural: { id: 'character_counter.remaining_plural', defaultMessage: 'characters remaining' },
  exceeded: { id: 'character_counter.exceeded', defaultMessage: 'You have exceeded the character limit by' },
});

export default @injectIntl
class CharacterCounter extends React.PureComponent {

  static propTypes = {
    text: PropTypes.string.isRequired,
    max: PropTypes.number.isRequired,
    intl: PropTypes.object.isRequired,
  };

  checkRemainingText(diff, intl) {
    if (diff < 0) {
      return (
        <>
          <span aria-hidden className='character-counter character-counter--over'>
            {diff}
          </span>
          <span className='sr-only'>
            {`${intl.formatMessage(messages.exceeded)} ${diff * -1}`}
          </span>
        </>
      );
    }

    return (
      <>
        <span aria-hidden className='character-counter'>
          {diff}
        </span>
        <span className='sr-only'>
          {`${diff} ${diff === 1 ? intl.formatMessage(messages.remaining) : intl.formatMessage(messages.remaining_plural)}`}
        </span>
      </>
    );
  }

  render() {
    const { intl } = this.props;
    const diff = this.props.max - length(this.props.text);
    return this.checkRemainingText(diff, intl);
  }

}
