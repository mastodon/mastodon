import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin    from 'react-addons-pure-render-mixin';

const DisplayName = React.createClass({

  propTypes: {
    account: ImmutablePropTypes.map.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    var displayName = this.props.account.get('display_name', this.props.account.get('username'));
    var acct        = this.props.account.get('acct');
    var url         = this.props.account.get('url');

    return (
      <a href={url} style={{ display: 'inline-block', color: '#616b86', textDecoration: 'none', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', width: '190px' }}>
        <strong style={{ fontWeight: 'bold', color: '#fff' }}>{displayName}</strong> <span>{acct}</span>
      </a>
    );
  }

});

export default DisplayName;
