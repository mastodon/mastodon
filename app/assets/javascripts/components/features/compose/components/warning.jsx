import PropTypes from 'prop-types';

class Warning extends React.PureComponent {

  constructor (props) {
    super(props);
  }

  render () {
    const { message } = this.props;

    return (
      <div className='compose-form__warning'>
        {message}
      </div>
    );
  }

}

Warning.propTypes = {
  message: PropTypes.node.isRequired
};

export default Warning;
