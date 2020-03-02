import React from 'react';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { fetchAccount } from '../../actions/accounts';
import { expandAccountFeaturedTimeline, expandAccountTimeline } from '../../actions/timelines';
import StatusList from '../../components/status_list';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import HeaderContainer from './containers/header_container';
import ColumnBackButton from '../../components/column_back_button';
import { List as ImmutableList } from 'immutable';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { FormattedMessage } from 'react-intl';
import { fetchAccountIdentityProofs } from '../../actions/identity_proofs';
import MissingIndicator from 'mastodon/components/missing_indicator';

const emptyList = ImmutableList();

const mapStateToProps = (state, { params: { accountId }, withReplies = false }) => {
  const path = withReplies ? `${accountId}:with_replies` : accountId;

  return {
    isAccount: !!state.getIn(['accounts', accountId]),
    statusIds: state.getIn(['timelines', `account:${path}`, 'items'], emptyList),
    featuredStatusIds: withReplies ? ImmutableList() : state.getIn(['timelines', `account:${accountId}:pinned`, 'items'], emptyList),
    isLoading: state.getIn(['timelines', `account:${path}`, 'isLoading']),
    hasMore: state.getIn(['timelines', `account:${path}`, 'hasMore']),
    blockedBy: state.getIn(['relationships', accountId, 'blocked_by'], false),
  };
};

export default @connect(mapStateToProps)
class AccountTimeline extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    statusIds: ImmutablePropTypes.list,
    featuredStatusIds: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    withReplies: PropTypes.bool,
    blockedBy: PropTypes.bool,
    isAccount: PropTypes.bool,
    multiColumn: PropTypes.bool,
  };

  componentWillMount () {
    const { params: { accountId }, withReplies } = this.props;

    this.props.dispatch(fetchAccount(accountId));
    this.props.dispatch(fetchAccountIdentityProofs(accountId));

    if (!withReplies) {
      this.props.dispatch(expandAccountFeaturedTimeline(accountId));
    }

    this.props.dispatch(expandAccountTimeline(accountId, { withReplies }));
  }

  componentWillReceiveProps (nextProps) {
    if ((nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) || nextProps.withReplies !== this.props.withReplies) {
      this.props.dispatch(fetchAccount(nextProps.params.accountId));
      this.props.dispatch(fetchAccountIdentityProofs(nextProps.params.accountId));

      if (!nextProps.withReplies) {
        this.props.dispatch(expandAccountFeaturedTimeline(nextProps.params.accountId));
      }

      this.props.dispatch(expandAccountTimeline(nextProps.params.accountId, { withReplies: nextProps.params.withReplies }));
    }
  }

  handleLoadMore = maxId => {
    this.props.dispatch(expandAccountTimeline(this.props.params.accountId, { maxId, withReplies: this.props.withReplies }));
  }

  render () {
    const { shouldUpdateScroll, statusIds, featuredStatusIds, isLoading, hasMore, blockedBy, isAccount, multiColumn } = this.props;

    if (!isAccount) {
      return (
        <Column>
          <ColumnBackButton multiColumn={multiColumn} />
          <MissingIndicator />
        </Column>
      );
    }

    if (!statusIds && isLoading) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = blockedBy ? <FormattedMessage id='empty_column.account_unavailable' defaultMessage='Profile unavailable' /> : <FormattedMessage id='empty_column.account_timeline' defaultMessage='No posts here!' />;

    return (
      <Column>
        <ColumnBackButton multiColumn={multiColumn} />

        <StatusList
          prepend={<HeaderContainer accountId={this.props.params.accountId} />}
          alwaysPrepend
          scrollKey='account_timeline'
          statusIds={blockedBy ? emptyList : statusIds}
          featuredStatusIds={featuredStatusIds}
          isLoading={isLoading}
          hasMore={hasMore}
          onLoadMore={this.handleLoadMore}
          shouldUpdateScroll={shouldUpdateScroll}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
          timelineId='account'
        />
      </Column>
    );
  }

}
