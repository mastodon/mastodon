import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import { connect } from 'react-redux';

import { revealAccount } from 'flavours/glitch/actions/accounts';
import Button from 'flavours/glitch/components/button';
import { domain } from 'flavours/glitch/initial_state';

const mapDispatchToProps = (dispatch, { accountId }) => ({

  reveal () {
    dispatch(revealAccount(accountId));
  },

});

class LimitedAccountHint extends PureComponent {

  static propTypes = {
    accountId: PropTypes.string.isRequired,
    reveal: PropTypes.func,
  };

  render () {
    const { reveal } = this.props;

    return (
      <div className='limited-account-hint'>
        <p><FormattedMessage id='limited_account_hint.title' defaultMessage='This profile has been hidden by the moderators of {domain}.' values={{ domain }} /></p>
        <Button onClick={reveal}><FormattedMessage id='limited_account_hint.action' defaultMessage='Show profile anyway' /></Button>
      </div>
    );
  }

}

export default connect(() => {}, mapDispatchToProps)(LimitedAccountHint);
