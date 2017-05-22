import React from 'react';
import PropTypes from 'prop-types';

class Warning extends React.PureComponent {

  static propTypes = {
    message: PropTypes.node.isRequired,
  };

  render () {
    const { message } = this.props;

    return (
      <div className='compose-form__warning'>
        {message}
      </div>
    );
  }

}

export default Warning;
