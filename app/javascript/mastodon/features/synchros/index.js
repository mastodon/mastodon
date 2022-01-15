import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import AccountContainer from '../../containers/account_container';
import ScrollableList from '../../components/scrollable_list';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { makeGetAccount } from '../../selectors';
import { debounce } from 'lodash';
import me from 'mastodon/initial_state';
import { fetchAccount } from '../../actions/accounts';
import { fetchSynchroBlocks, expandSynchroBlocks } from '../../actions/blocks';
import { blockAccount } from '../../actions/accounts'

const messages = defineMessages({
    heading: { id: 'column.synchros', defaultMessage: 'Blocked Users from Synchros' },
    synchronized: { id: 'blocks.blockall', defaultMessage: 'Block All' },
    synchronization: { id: 'blocks.synchronization', defaultMessage: 'Blocks to Synchronize' },
    emptyMessage: { id: 'empty_column.synchros', defaultMessage: "You don't have users to block from synchronization" }
});

const makeMapStateToProps = () => {

    const getAccount = makeGetAccount();

    const mapStateToProps = (state) => ({
        account: getAccount(state, me.compose.me),
        accounts: fetchJson(state),
        accountIds: state.getIn(['user_lists', 'synchros', 'items']),
        hasMore: !!state.getIn(['user_lists', 'synchros', 'next']),
        isLoading: state.getIn(['user_lists', 'synchros', 'isLoading'], true),
    });
    return mapStateToProps;
};

const fetchJson = (state) => {
    if (state.getIn(['accounts', me.compose.me, 'block_synchro_list']) !== null)
        return JSON.parse(state.getIn(['accounts', me.compose.me, 'block_synchro_list']));
    return [];
}

var result = [];

export default @connect(makeMapStateToProps)
@injectIntl
class Synchros extends ImmutablePureComponent {

    static propTypes = {
        account: ImmutablePropTypes.map.isRequired,
        accounts: PropTypes.array.isRequired,
        accountIds: ImmutablePropTypes.list,
        dispatch: PropTypes.func.isRequired,
        hasMore: PropTypes.bool,
        isLoading: PropTypes.bool,
        intl: PropTypes.object.isRequired,
        multiColumn: PropTypes.bool,
    };

    componentDidMount() {
        result = [];
        this.props.dispatch(fetchAccount(me.compose.me));
        this.props.accounts.map(x => this.props.dispatch(fetchSynchroBlocks(x.id)));
        console.log(this.props.accountIds);
        console.log(this.props.accounts);
    }

    componentDidUpdate() {
        this.props.accountIds.map(x => result.push(x.toString()));

        result = result.filter((w, index) => {
            return result.indexOf(w) === index;
        }).filter(id => id !== me.compose.me);
    }

    handleLoadMore = debounce(() => {
        this.props.dispatch(expandSynchroBlocks());
    }, 300, { leading: true });

    handleClick = () => {
        result.map(x => this.props.dispatch(blockAccount(x)));
    }

    isEmpty = (obj) => {
        for (var key in obj) {
            if (obj.hasOwnProperty(key))
                return false;
        }
        return true;
    }

    render() {
        const { intl, multiColumn, accountIds, hasMore, isLoading, } = this.props;

        const emptyMessage = <FormattedMessage id='empty_column.synchros' defaultMessage="You don't have users to block from synchronization" />;

        if (!accountIds) {
            return (
                <Column>
                    <LoadingIndicator />
                </Column>
            );
        }
        return (
            <Column bindToDocument={!multiColumn} icon='ban' heading={intl.formatMessage(messages.heading)}>
                <ColumnBackButtonSlim />
                <div className="wrapper-import">
                    {<div >
                        <button onClick={this.handleClick} className='button-import'>
                            <FormattedMessage id='blocks.blockall' defaultMessage='Block All' />
                        </button>
                    </div>}
                    <div  >
                        <span className='message-import'> {intl.formatMessage(messages.synchronization)} </span>
                    </div>
                </div>
                <ScrollableList
                    scrollKey='synchros'
                    onLoadMore={this.handleLoadMore}
                    hasMore={hasMore}
                    isLoading={isLoading}
                    emptyMessage={emptyMessage}
                    bindToDocument={!multiColumn}
                >
                    {result.map(id =>
                        <AccountContainer key={id} id={id} />,
                    )}
                </ScrollableList>
            </Column>
        );
    }

}