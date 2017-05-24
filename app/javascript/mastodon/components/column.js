import React from 'react';
import PropTypes from 'prop-types';

class Column extends React.PureComponent {

  static propTypes = {
    children: PropTypes.node,
  };

  render () {
    const { children } = this.props;

    return (
      <div role='region' className='column'>
        {children}
      </div>
    );
  }

}

export default Column;
