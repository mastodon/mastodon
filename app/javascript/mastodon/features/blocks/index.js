import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes, { list } from 'react-immutable-proptypes';
import { debounce, identity } from 'lodash';
import PropTypes from 'prop-types';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import me from 'mastodon/initial_state';
import AccountContainer from '../../containers/account_container';
import { fetchBlocks, expandBlocks } from '../../actions/blocks';
import ScrollableList from '../../components/scrollable_list';
import { makeGetAccount } from '../../selectors';
import { blockAccount } from '../../actions/accounts';
import { openModal } from '../../actions/modal';



const messages = defineMessages({
  heading: { id: 'column.blocks', defaultMessage: 'Blocked users' },
  question: { id: 'modal.information', defaultMessage: 'Are you sure you want to import users blocked by {name}?' },
  confirm: { id: 'confirmations.confirm', defaultMessage: 'Confirm' },
  import: { id: 'button.import', defaultMessage: 'Import' },
  blockedBy: { id: 'column.blockedBy', defaultMessage: 'Users blocked by @{name}' },
  importMessage: { id: 'column.importMessage', defaultMessage: 'Imported {counter} users' },
  denyMessage: { id: 'column.denyMessage', defaultMessage: 'Cannot import from yourself' },
});
const getAccount = makeGetAccount()

const getBlocks = (state, accountIds) => {
  return accountIds.map(a => getAccount(state, a))
}

const makeMapStateToProps = () => {
  const mapStateToProps = (state, props) => ({
    accountIds: state.getIn(['user_lists', 'blocks', 'items']),
    hasMore: !!state.getIn(['user_lists', 'blocks', 'next']),
    isLoading: state.getIn(['user_lists', 'blocks', 'isLoading'], true),
    accounts: getBlocks(state, state.getIn(['user_lists', 'blocks', 'items'])),
    account: getAccount(state, props.params.id),
  });

  return mapStateToProps;
};

export default @connect(makeMapStateToProps)
@injectIntl
class Blocks extends ImmutablePureComponent {
  state = {
    showMessage: false,
    showDenyMessage: false,
    count: 0,
  }
  static propTypes = {
    params: PropTypes.object.isRequired,
    account: ImmutablePropTypes.map,
    accounts: ImmutablePropTypes.list.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    accountIds: ImmutablePropTypes.list,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  componentWillMount() {
    const { id } = this.props.params;
    this.props.dispatch(fetchBlocks(id));
    this.setState({ showMessage: false, showDenyMessage: false, count: 0, })
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandBlocks());
  }, 300, { leading: true });


  handleClick = () => {
    if (this.props.params.id == me.compose.me) {
      this.setState({ showDenyMessage: true, showMessage: false,})
    }
    else {
      var counter = 0;
      this.props.dispatch(openModal('CONFIRM', {
        message: <FormattedMessage id='modal.information' defaultMessage='Are you sure you want to import users blocked by {name}?' values={{ name: this.props.account.get('username') }} />,
        confirm: this.props.intl.formatMessage({ id: 'confirmations.confirm', defaultMessage: "Confirm" }),
        onConfirm: () => {
          this.props.accounts.map((acc) => {
            if (acc.getIn(['relationship', 'blocking'])) {
            } else {
              this.props.dispatch(blockAccount(acc.get('id')));
              counter += 1
            }
          })
          this.setState({ showMessage: true, showDenyMessage: false, count: counter, })
        },
      }));
    }
  }

  render() {
    const { intl, accountIds, shouldUpdateScroll, hasMore, multiColumn, isLoading, params, account, id } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.blocks' defaultMessage="This user haven't blocked any users yet." />;
    return (
      <Column bindToDocument={!multiColumn} icon='ban' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />

        <div className="wrapper-import">
          <div >
            <button onClick={this.handleClick} className='button-import'>
              <FormattedMessage id='button.import' defaultMessage='Import' />
            </button>
          </div>
          <div>
            {this.state.showMessage && <span className='message-import'> {intl.formatMessage(messages.importMessage, { counter: this.state.count })}</span>}
            {this.state.showDenyMessage && <span className='message-import'> {intl.formatMessage(messages.denyMessage)} </span>}
          </div>
          <div  >
            <span className='message-import'> {intl.formatMessage(messages.blockedBy, { name: account.get('username') })} </span>
          </div>
        </div>

        <ScrollableList
          scrollKey='blocks'
          onLoadMore={this.handleLoadMore}
          hasMore={hasMore}
          isLoading={isLoading}
          shouldUpdateScroll={shouldUpdateScroll}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        >
          {accountIds.map(id =>
            <AccountContainer key={id} id={id} />,
          )}
        </ScrollableList>
      </Column>
    );
  }
}
