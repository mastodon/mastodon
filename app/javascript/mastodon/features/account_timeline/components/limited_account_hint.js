import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { revealAccount } from 'mastodon/actions/accounts';
import { FormattedMessage } from 'react-intl';
import Button from 'mastodon/components/button';

const mapDispatchToProps = (dispatch, { accountId }) => ({

  reveal () {
    dispatch(revealAccount(accountId));
  },

});

export default @connect(() => {}, mapDispatchToProps)
class LimitedAccountHint extends React.PureComponent {

  static propTypes = {
    accountId: PropTypes.string.isRequired,
    reveal: PropTypes.func,
  }

  render () {
    const { reveal } = this.props;

    return (
      <div className='limited-account-hint'>
        <p><FormattedMessage id='limited_account_hint.title' defaultMessage='This profile has been hidden by the moderators of your server.' /></p>
        <Button onClick={reveal}><FormattedMessage id='limited_account_hint.action' defaultMessage='Show profile anyway' /></Button>
      </div>
    );
  }

}
