import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';

class ColumnBackButton extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick () {
    if (window.history && window.history.length === 1) this.context.router.push("/");
    else this.context.router.goBack();
  }

  render () {
    return (
      <div role='button' tabIndex='0' onClick={this.handleClick} className='column-back-button'>
        <i className='fa fa-fw fa-chevron-left column-back-button__icon'/>
        <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
      </div>
    );
  }

};

ColumnBackButton.contextTypes = {
  router: PropTypes.object
};

export default ColumnBackButton;
