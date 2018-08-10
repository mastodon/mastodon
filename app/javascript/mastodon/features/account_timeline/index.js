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

const mapStateToProps = (state, { params: { accountId }, withReplies = false }) => {
  const path = withReplies ? `${accountId}:with_replies` : accountId;

  return {
    statusIds: state.getIn(['timelines', `account:${path}`, 'items'], ImmutableList()),
    featuredStatusIds: withReplies ? ImmutableList() : state.getIn(['timelines', `account:${accountId}:pinned`, 'items'], ImmutableList()),
    isLoading: state.getIn(['timelines', `account:${path}`, 'isLoading']),
    hasMore:   state.getIn(['timelines', `account:${path}`, 'hasMore']),
  };
};

@connect(mapStateToProps)
export default class AccountTimeline extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    statusIds: ImmutablePropTypes.list,
    featuredStatusIds: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    withReplies: PropTypes.bool,
  };

  componentWillMount () {
    const { params: { accountId }, withReplies } = this.props;

    this.props.dispatch(fetchAccount(accountId));
    if (!withReplies) {
      this.props.dispatch(expandAccountFeaturedTimeline(accountId));
    }
    this.props.dispatch(expandAccountTimeline(accountId, { withReplies }));
  }

  componentWillReceiveProps (nextProps) {
    if ((nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) || nextProps.withReplies !== this.props.withReplies) {
      this.props.dispatch(fetchAccount(nextProps.params.accountId));
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
    const { shouldUpdateScroll, statusIds, featuredStatusIds, isLoading, hasMore } = this.props;

    if (!statusIds && isLoading) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column>
        <ColumnBackButton />

        <StatusList
          prepend={<HeaderContainer accountId={this.props.params.accountId} />}
          scrollKey='account_timeline'
          statusIds={statusIds}
          featuredStatusIds={featuredStatusIds}
          isLoading={isLoading}
          hasMore={hasMore}
          onLoadMore={this.handleLoadMore}
          shouldUpdateScroll={shouldUpdateScroll}
        />
      </Column>
    );
  }

}
