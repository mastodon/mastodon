import React from 'react';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { debounce } from 'lodash';
import LoadingIndicator from '../../components/loading_indicator';
import {
  fetchAccount,
  fetchFollowing,
  expandFollowing,
} from '../../actions/accounts';
import { FormattedMessage } from 'react-intl';
import AccountContainer from '../../containers/account_container';
import Column from '../ui/components/column';
import HeaderContainer from '../account_timeline/containers/header_container';
import ColumnBackButton from '../../components/column_back_button';
import ScrollableList from '../../components/scrollable_list';
import MissingIndicator from 'mastodon/components/missing_indicator';

const mapStateToProps = (state, props) => ({
  isAccount: !!state.getIn(['accounts', props.params.accountId]),
  accountIds: state.getIn(['user_lists', 'following', props.params.accountId, 'items']),
  hasMore: !!state.getIn(['user_lists', 'following', props.params.accountId, 'next']),
  blockedBy: state.getIn(['relationships', props.params.accountId, 'blocked_by'], false),
});

export default @connect(mapStateToProps)
class Following extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    accountIds: ImmutablePropTypes.list,
    hasMore: PropTypes.bool,
    blockedBy: PropTypes.bool,
    isAccount: PropTypes.bool,
    multiColumn: PropTypes.bool,
  };

  componentWillMount () {
    if (!this.props.accountIds) {
      this.props.dispatch(fetchAccount(this.props.params.accountId));
      this.props.dispatch(fetchFollowing(this.props.params.accountId));
    }
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) {
      this.props.dispatch(fetchAccount(nextProps.params.accountId));
      this.props.dispatch(fetchFollowing(nextProps.params.accountId));
    }
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandFollowing(this.props.params.accountId));
  }, 300, { leading: true });

  render () {
    const { shouldUpdateScroll, accountIds, hasMore, blockedBy, isAccount, multiColumn } = this.props;

    if (!isAccount) {
      return (
        <Column>
          <MissingIndicator />
        </Column>
      );
    }

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = blockedBy ? <FormattedMessage id='empty_column.account_unavailable' defaultMessage='Profile unavailable' /> : <FormattedMessage id='account.follows.empty' defaultMessage="This user doesn't follow anyone yet." />;

    return (
      <Column>
        <ColumnBackButton multiColumn={multiColumn} />

        <ScrollableList
          scrollKey='following'
          hasMore={hasMore}
          onLoadMore={this.handleLoadMore}
          shouldUpdateScroll={shouldUpdateScroll}
          prepend={<HeaderContainer accountId={this.props.params.accountId} hideTabs />}
          alwaysPrepend
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        >
          {blockedBy ? [] : accountIds.map(id =>
            <AccountContainer key={id} id={id} withNote={false} />,
          )}
        </ScrollableList>
      </Column>
    );
  }

}
