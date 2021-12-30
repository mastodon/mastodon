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
import me from 'mastodon/initial_state';
import { fetchAccount } from '../../actions/accounts';
import { fetchBlocks } from '../../actions/blocks';

const messages = defineMessages({
    heading: { id: 'column.blocks', defaultMessage: 'Blocked users' },
});

const makeMapStateToProps = () => {

    const getAccount = makeGetAccount();

    const mapStateToProps = (state, props) => ({
        account: getAccount(state, me.compose.me),
        accounts: JSON.parse(state.getIn(['accounts', me.compose.me, 'block_synchro_list'])),

    });
    return mapStateToProps;
};

export default @connect(makeMapStateToProps)
@injectIntl
class Synchros extends ImmutablePureComponent {

    static propTypes = {
        account: ImmutablePropTypes.map,
        accounts: PropTypes.array.isRequired,
        dispatch: PropTypes.func.isRequired,
        hasMore: PropTypes.bool,
        isLoading: PropTypes.bool,
        intl: PropTypes.object.isRequired,
        multiColumn: PropTypes.bool,
    };

    state = {
        accountIds: null,
    }

    componentDidMount() {
        this.props.dispatch(fetchAccount(me.compose.me));
        // this.fetchSynchros(this.props.account)
    }

    handleClick = () => {
        console.log(this.isEmpty(this.props.accounts));
        this.props.accounts.map(x => console.log(x.id));
        // console.log();
        // console.log(this.props.account.get("block_synchro_list"));
    }

    fetchSynchros = (account) => {
        console.log(this.state.accountIds)
        var json = JSON.parse(account.get("block_synchro_list"))
        json = Object.values(json);
        const accountIds = json.map(x => this.props.dispatch(fetchBlocks(x.id)));
        // this.setState({ accountIds: accountIds });
        return accountIds;
    }


  isEmpty = (obj) => {
    for (var key in obj) {
      if (obj.hasOwnProperty(key))
        return false;
    }
    return true;
  }

    render() {
        const { intl, hasMore, multiColumn, isLoading, accounts } = this.props;

        const emptyMessage = <FormattedMessage id='empty_column.blocks' defaultMessage="You haven't blocked any users yet." />;

        if (this.isEmpty(accounts)) {
            return (
                <Column>
                    <LoadingIndicator />
                </Column>
            );
        }
        return (
            <Column bindToDocument={!multiColumn} icon='ban' heading={intl.formatMessage(messages.heading)}>
                <ColumnBackButtonSlim />
                {<div >
                    <button onClick={this.handleClick} className='button-import'>
                        <FormattedMessage id='button.import' defaultMessage='Import' />
                    </button>
                </div>}
                <ScrollableList
                    scrollKey='synchros'
                    hasMore={hasMore}
                    isLoading={isLoading}
                    emptyMessage={emptyMessage}
                    bindToDocument={!multiColumn}
                >
                    {accounts.map(id =>
                        <AccountContainer key={id.id} id={id.id} />,
                    )}
                </ScrollableList>
            </Column>
        );
    }

}