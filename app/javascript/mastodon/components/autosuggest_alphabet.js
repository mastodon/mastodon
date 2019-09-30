import React from 'react';
import PropTypes from 'prop-types';

export default class AutosuggestAlphabet extends React.PureComponent {

  static propTypes = {
    alphabet: PropTypes.shape({
      item: PropTypes.string.isRequired,
    }).isRequired,
  };

  render () {
    const { alphabet } = this.props;

    return (
      <div className='autosuggest-alphabet'>
        <div className='autosuggest-alphabet__name'>{alphabet.item}</div>
      </div>
    );
  }

}
