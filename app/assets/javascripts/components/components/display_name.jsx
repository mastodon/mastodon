import ImmutablePropTypes from 'react-immutable-proptypes';

const DisplayName = React.createClass({

  propTypes: {
    account: ImmutablePropTypes.map.isRequired
  },

  render () {
    let displayName = this.props.account.get('display_name');

    if (displayName.length === 0) {
      displayName = this.props.account.get('username');
    }

    return (
      <span style={{ display: 'block', maxWidth: '100%', overflow: 'hidden', whiteSpace: 'nowrap', textOverflow: 'ellipsis' }}>
        <strong style={{ fontWeight: 'bold' }}>{displayName}</strong> <span style={{ fontSize: '14px' }}>@{this.props.account.get('acct')}</span>
      </span>
    );
  }

});

export default DisplayName;
