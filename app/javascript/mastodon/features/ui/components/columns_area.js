import React from 'react';
import PropTypes from 'prop-types';

class ColumnsArea extends React.PureComponent {

  render () {
    return (
      <div className='columns-area'>
        {this.props.children}
      </div>
    );
  }

}

ColumnsArea.propTypes = {
  children: PropTypes.node
};

export default ColumnsArea;
