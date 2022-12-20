import React from 'react';
import PropTypes from 'prop-types';
import { length } from 'stringz';

export default class CharacterCounter extends React.PureComponent {

  static propTypes = {
    text: PropTypes.string.isRequired,
    max: PropTypes.number.isRequired,
  };

  checkRemainingText(diff) {
    if (diff < 0) {
      return (
        <>
          <span aria-hidden className='character-counter character-counter--over'>
            {diff}
          </span>
          <span className='sr-only'>
            {`You have exceeded the character limit by ${diff * -1}`}
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
          {`${diff} character${diff === 1 ? '' : 's'} remaining`}
        </span>
      </>
    );
  }

  render() {
    const diff = this.props.max - length(this.props.text);
    return this.checkRemainingText(diff);
  }

}
