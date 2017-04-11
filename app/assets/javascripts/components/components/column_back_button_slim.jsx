import PureRenderMixin from 'react-addons-pure-render-mixin';
import { FormattedMessage } from 'react-intl';
import Icon from './icon';

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

const ColumnBackButtonSlim = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  mixins: [PureRenderMixin],

  handleClick () {
    this.context.router.push('/');
  },

  render () {
    return (
      <div style={{ position: 'relative' }}>
        <div style={outerStyle} onClick={this.handleClick} className='column-back-button'>
          <Icon icon='chevron-left' style={iconStyle} fixedWidth={true} />
          <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
        </div>
      </div>
    );
  }

});

export default ColumnBackButtonSlim;
