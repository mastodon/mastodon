import React from 'react';
import PropTypes from 'prop-types';

export default class CharacterCounter extends React.PureComponent {

  static propTypes = {
    textLength: PropTypes.number.isRequired,
    max: PropTypes.number.isRequired,
  };

  checkRemainingText (diff) {
    if (diff < 0) {
      return <span className='character-counter character-counter--over'>{diff}</span>;
    }

    return <span className='character-counter'>{diff}</span>;
  }

  render () {
    const diff = this.props.max - this.props.textLength;
    return this.checkRemainingText(diff);
  }

}
