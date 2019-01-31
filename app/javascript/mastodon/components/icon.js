import React from 'react';
import PropTypes from 'prop-types';

export default class Icon extends React.PureComponent {

  static propTypes = {
    className: PropTypes.string.isRequired,
  };

  render () {
    const { className } = this.props;

    return (
      <i className={className} />
    );
  }

}
