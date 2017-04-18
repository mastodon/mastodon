import PureRenderMixin from 'react-addons-pure-render-mixin';
import { FormattedMessage } from 'react-intl';

const iconStyle = {
  display: 'inline-block',
  marginRight: '5px'
};

const ColumnBackButton = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  mixins: [PureRenderMixin],

  handleClick () {
    if (window.history && window.history.length === 1) this.context.router.push("/");
    else this.context.router.goBack();
  },

  render () {
    return (
      <div role='button' tabIndex='0' onClick={this.handleClick} className='column-back-button'>
        <i className='fa fa-fw fa-chevron-left' style={iconStyle} />
        <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
      </div>
    );
  }

});

export default ColumnBackButton;
