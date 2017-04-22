import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';

const outerStyle = {
  position: 'absolute',
  right: '0',
  top: '-48px',
  padding: '15px',
  fontSize: '16px',
  flex: '0 0 auto',
  cursor: 'pointer'
};

const iconStyle = {
  display: 'inline-block',
  marginRight: '5px'
};

class ColumnBackButtonSlim extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick () {
    this.context.router.push('/');
  }

  render () {
    return (
      <div style={{ position: 'relative' }}>
        <div role='button' tabIndex='0' style={outerStyle} onClick={this.handleClick} className='column-back-button'>
          <i className='fa fa-fw fa-chevron-left' style={iconStyle} />
          <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
        </div>
      </div>
    );
  }

}

ColumnBackButtonSlim.contextTypes = {
  router: PropTypes.object
};

export default ColumnBackButtonSlim;
