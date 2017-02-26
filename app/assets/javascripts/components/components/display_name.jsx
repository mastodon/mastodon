import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import escapeTextContentForBrowser from 'escape-html';
import emojify from '../emoji';

const DisplayName = React.createClass({

  propTypes: {
    account: ImmutablePropTypes.map.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const displayName     = this.props.account.get('display_name').length === 0 ? this.props.account.get('username') : this.props.account.get('display_name');
    const displayNameHTML = { __html: emojify(escapeTextContentForBrowser(displayName)) };

    return (
      <span style={{ display: 'block', maxWidth: '100%', overflow: 'hidden', whiteSpace: 'nowrap', textOverflow: 'ellipsis' }} className='display-name'>
        <strong style={{ fontWeight: '500' }} dangerouslySetInnerHTML={displayNameHTML} /> <span style={{ fontSize: '14px' }}>@{this.props.account.get('acct')}</span>
      </span>
    );
  }

});

export default DisplayName;
