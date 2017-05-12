import React from 'react';
import PropTypes from 'prop-types';

class ColumnsArea extends React.PureComponent {

  static propTypes = {
    children: PropTypes.node
  };

  render () {
    return (
      <div className='columns-area'>
        {this.props.children}
      </div>
    );
  }

}

export default ColumnsArea;
