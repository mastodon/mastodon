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
import ImportBlocksButton from '../../components/import_blocks_button';
import AccountContainer from '../../containers/account_container';
import { fetchBlocks, expandBlocks } from '../../actions/blocks';
import ScrollableList from '../../components/scrollable_list';
import { makeGetAccount } from '../../selectors';


const messages = defineMessages({
  heading: { id: 'column.blocks', defaultMessage: 'Blocked users' },
});

const getBlocks = (state, accountIds) => {
  const getAccount = makeGetAccount()
  return accountIds.map(a => getAccount(state, a))
}

const makeMapStateToProps = () => {
  const mapStateToProps = (state) => ({
    accountIds: state.getIn(['user_lists', 'blocks', 'items']),
    hasMore: !!state.getIn(['user_lists', 'blocks', 'next']),
    isLoading: state.getIn(['user_lists', 'blocks', 'isLoading'], true),
    accounts: getBlocks(state, state.getIn(['user_lists', 'blocks', 'items'])),
  });

  return mapStateToProps;
};

export default @connect(makeMapStateToProps)
@injectIntl
class Blocks extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    id: PropTypes.string,
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
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandBlocks());
  }, 300, { leading: true });

  render() {
    const { intl, accountIds, shouldUpdateScroll, hasMore, multiColumn, isLoading, accounts } = this.props;

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
        <ImportBlocksButton accounts={accounts} />

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
