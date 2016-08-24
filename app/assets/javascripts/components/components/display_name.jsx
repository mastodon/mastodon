import ImmutablePropTypes from 'react-immutable-proptypes';

const DisplayName = React.createClass({
  propTypes: {
    account: ImmutablePropTypes.map.isRequired
  },

  render () {
    var displayName = this.props.account.get('display_name', this.props.account.get('username'));
    var acct        = this.props.account.get('acct');
    var url         = this.props.account.get('url');

    return (
      <a href={url} style={{ color: '#616b86', textDecoration: 'none' }}>
        <strong style={{ fontWeight: 'bold', color: '#fff' }}>{displayName}</strong> <span>{acct}</span>
      </a>
    );
  }

});

export default DisplayName;
