import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { debounce } from 'lodash';
import PropTypes from 'prop-types';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import me from 'mastodon/initial_state';
import AccountContainer from '../../containers/account_container';
import { fetchBlocks, expandBlocks } from '../../actions/blocks';
import ScrollableList from '../../components/scrollable_list';
import { makeGetAccount } from '../../selectors';
import { blockAccount, synchronizeBlocks } from '../../actions/accounts';
import { fetchAccount } from '../../actions/accounts';
import { openModal } from '../../actions/modal';


const messages = defineMessages({
  heading: { id: 'column.blocks', defaultMessage: 'Blocked users' },
  question: { id: 'modal.information', defaultMessage: 'Are you sure you want to import users blocked by {name}?' },
  confirm: { id: 'confirmations.confirm', defaultMessage: 'Confirm' },
  import: { id: 'button.import', defaultMessage: 'Import' },
  blockedBy: { id: 'column.blockedBy', defaultMessage: 'Users blocked by @{name}' },
  importMessage: { id: 'column.importMessage', defaultMessage: 'Imported {counter} users' },
  denyMessage: { id: 'column.denyMessage', defaultMessage: 'Cannot import from yourself' },
  synchronize: { id: 'button.synchronize', defaultMessage: 'Synchronize' },
  unsynchronize: { id: 'button.unsynchronize', defaultMessage: 'Unsynchronize' },
});

const makeMapStateToProps = () => {

  const getAccount = makeGetAccount();

  const getBlocks = (state, accountIds) => {
    return accountIds.map(a => getAccount(state, a))
  }

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.params.id),
    myAccount: getAccount(state, me.compose.me),
    accountIds: state.getIn(['user_lists', 'blocks', 'items']),
    hasMore: !!state.getIn(['user_lists', 'blocks', 'next']),
    isLoading: state.getIn(['user_lists', 'blocks', 'isLoading'], true),
    accounts: getBlocks(state, state.getIn(['user_lists', 'blocks', 'items'])),
  });
  return mapStateToProps;
};

export default 
@injectIntl
@connect(makeMapStateToProps)
class Blocks extends ImmutablePureComponent {
  state = {
    showMessage: false,
    showDenyMessage: false,
    synchronized: false,
    count: 0,
  }
  static propTypes = {
    params: PropTypes.object.isRequired,
    account: ImmutablePropTypes.map,
    myAccount: ImmutablePropTypes.map,
    accounts: ImmutablePropTypes.list.isRequired,
    dispatch: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  componentDidMount() {
    const { id } = this.props.params;
    const { dispatch } = this.props;
    this.setState({ showMessage: false, showDenyMessage: false, synchronized: false, count: 0, })
    dispatch(fetchBlocks(id));
    dispatch(fetchAccount(id))
    const text = JSON.parse(this.props.myAccount.get("block_synchro_list"));
    this.setState({
      synchronized: this.checkSynchronization(text),
    });
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandBlocks());
  }, 300, { leading: true });

  handleClickImportBlocks = () => {
    if (this.props.params.id == me.compose.me) {
      this.setState({ showDenyMessage: true, showMessage: false, })
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

  checkIfIn = (json, value) => {
    json = Object.values(json);
    return this.isEmpty(json.filter(x => x.id == value));
  }

  handleClickSynchronizeBlocks = () => {
    const text = JSON.parse(this.props.myAccount.get("block_synchro_list"));
    if (text == null) {
      json = { "id": this.props.params.id };
      this.props.dispatch(synchronizeBlocks(me.compose.me, JSON.stringify(json)));
    }
    else {
      var json = Object.values(text);
      this.checkSynchronization(json);
      if (!this.state.synchronized) {
        if (this.checkIfIn(json, this.props.params.id)) {
          json = json.filter(value => this.isEmpty(value) == false);
          json = json.filter(value => value.id !== undefined);
          json.push({ "id": this.props.params.id });
          this.props.dispatch(synchronizeBlocks(me.compose.me, JSON.stringify(json)));
        }
      }
      else {
        json = json.filter(x => x.id !== this.props.params.id).filter(value => this.isEmpty(value) == false).filter(value => value.id !== undefined);
        this.props.dispatch(synchronizeBlocks(me.compose.me, JSON.stringify(json)));
      }
    }
    this.checkSynchronization(json);
    this.props.dispatch(fetchAccount(me.compose.me))
  }

  checkSynchronization = (text) => {
    if (text == null) {
      this.setState({ synchronized: false, })
      return false;
    }
    const result = !this.checkIfIn(text, this.props.params.id);
    this.setState({ synchronized: result, })
    return result;
  }

  isEmpty = (obj) => {
    for (var key in obj) {
      if (obj.hasOwnProperty(key))
        return false;
    }
    return true;
  }

  render() {
    const { intl, accountIds, hasMore, multiColumn, isLoading, account, params } = this.props;

    if (!accountIds || (!account && me.compose.me != params.id)) {
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
          {me.compose.me !== params.id &&
            <div >
              <button onClick={this.handleClickImportBlocks} className='button-import'>
                <FormattedMessage id='button.import' defaultMessage='Import' />
              </button>
            </div>}
          {me.compose.me !== params.id && !this.state.synchronized &&
            <div>
              <button onClick={this.handleClickSynchronizeBlocks} className='button-import'>
                <FormattedMessage id='button.synchronize' defaultMessage='Synchronize' />
              </button>
            </div>}
          {me.compose.me !== params.id && this.state.synchronized &&
            <div>
              <button onClick={this.handleClickSynchronizeBlocks} className='button-import'>
                <FormattedMessage id='button.unsynchronize' defaultMessage='Unsynchronize' />
              </button>
            </div>}
          {me.compose.me !== params.id &&
            <div  >
              <span className='message-import'> {intl.formatMessage(messages.blockedBy, { name: account.get('username') })} </span>
            </div>}
        </div>
        {
          (account.get('show_blocked_users') || me.compose.me == params.id) &&
          <ScrollableList
            scrollKey='blocks'
            onLoadMore={this.handleLoadMore}
            hasMore={hasMore}
            isLoading={isLoading}
            emptyMessage={emptyMessage}
            bindToDocument={!multiColumn}
          >
            {accountIds.map(id =>
              <AccountContainer key={id} id={id} />,
            )}
          </ScrollableList>
        }
      </Column >
    );
  }
}
