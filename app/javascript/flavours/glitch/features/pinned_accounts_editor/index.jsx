import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { injectIntl, FormattedMessage } from 'react-intl';
import { fetchPinnedAccounts, clearPinnedAccountsSuggestions, resetPinnedAccountsEditor } from 'flavours/glitch/actions/accounts';
import AccountContainer from './containers/account_container';
import SearchContainer from './containers/search_container';
import Motion from 'flavours/glitch/features/ui/util/optional_motion';
import spring from 'react-motion/lib/spring';

const mapStateToProps = state => ({
  accountIds: state.getIn(['pinnedAccountsEditor', 'accounts', 'items']),
  searchAccountIds: state.getIn(['pinnedAccountsEditor', 'suggestions', 'items']),
});

const mapDispatchToProps = dispatch => ({
  onInitialize: () => dispatch(fetchPinnedAccounts()),
  onClear: () => dispatch(clearPinnedAccountsSuggestions()),
  onReset: () => dispatch(resetPinnedAccountsEditor()),
});

class PinnedAccountsEditor extends ImmutablePureComponent {

  static propTypes = {
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    onInitialize: PropTypes.func.isRequired,
    onClear: PropTypes.func.isRequired,
    onReset: PropTypes.func.isRequired,
    title: PropTypes.string.isRequired,
    accountIds: ImmutablePropTypes.list.isRequired,
    searchAccountIds: ImmutablePropTypes.list.isRequired,
  };

  componentDidMount () {
    const { onInitialize } = this.props;
    onInitialize();
  }

  componentWillUnmount () {
    const { onReset } = this.props;
    onReset();
  }

  render () {
    const { accountIds, searchAccountIds, onClear } = this.props;
    const showSearch = searchAccountIds.size > 0;

    return (
      <div className='modal-root__modal list-editor'>
        <h4><FormattedMessage id='endorsed_accounts_editor.endorsed_accounts' defaultMessage='Featured accounts' /></h4>

        <SearchContainer />

        <div className='drawer__pager'>
          <div className='drawer__inner list-editor__accounts'>
            {accountIds.map(accountId => <AccountContainer key={accountId} accountId={accountId} added />)}
          </div>

          {showSearch && <div role='button' tabIndex='-1' className='drawer__backdrop' onClick={onClear} />}

          <Motion defaultStyle={{ x: -100 }} style={{ x: spring(showSearch ? 0 : -100, { stiffness: 210, damping: 20 }) }}>
            {({ x }) =>
              (<div className='drawer__inner backdrop' style={{ transform: x === 0 ? null : `translateX(${x}%)`, visibility: x === -100 ? 'hidden' : 'visible' }}>
                {searchAccountIds.map(accountId => <AccountContainer key={accountId} accountId={accountId} />)}
              </div>)
            }
          </Motion>
        </div>
      </div>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(injectIntl(PinnedAccountsEditor));
