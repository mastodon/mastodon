import PropTypes from 'prop-types';

const style = {
  display: 'flex',
  flex: '1 1 auto',
  overflowX: 'auto'
};

class ColumnsArea extends React.PureComponent {

  render () {
    return (
      <div className='columns-area' style={style}>
        {this.props.children}
      </div>
    );
  }

}

ColumnsArea.propTypes = {
  children: PropTypes.node
};

export default ColumnsArea;
