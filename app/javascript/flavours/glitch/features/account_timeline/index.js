import React from 'react';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { fetchAccount } from 'flavours/glitch/actions/accounts';
import { expandAccountFeaturedTimeline, expandAccountTimeline } from 'flavours/glitch/actions/timelines';
import StatusList from '../../components/status_list';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import ProfileColumnHeader from 'flavours/glitch/features/account/components/profile_column_header';
import HeaderContainer from './containers/header_container';
import ColumnBackButton from 'flavours/glitch/components/column_back_button';
import { List as ImmutableList } from 'immutable';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { FormattedMessage } from 'react-intl';
import { fetchAccountIdentityProofs } from '../../actions/identity_proofs';
import MissingIndicator from 'flavours/glitch/components/missing_indicator';
import TimelineHint from 'flavours/glitch/components/timeline_hint';

const emptyList = ImmutableList();

const mapStateToProps = (state, { params: { accountId }, withReplies = false }) => {
  const path = withReplies ? `${accountId}:with_replies` : accountId;

  return {
    remote: !!(state.getIn(['accounts', accountId, 'acct']) !== state.getIn(['accounts', accountId, 'username'])),
    remoteUrl: state.getIn(['accounts', accountId, 'url']),
    isAccount: !!state.getIn(['accounts', accountId]),
    statusIds: state.getIn(['timelines', `account:${path}`, 'items'], ImmutableList()),
    featuredStatusIds: withReplies ? ImmutableList() : state.getIn(['timelines', `account:${accountId}:pinned`, 'items'], ImmutableList()),
    isLoading: state.getIn(['timelines', `account:${path}`, 'isLoading']),
    hasMore:   state.getIn(['timelines', `account:${path}`, 'hasMore']),
    suspended: state.getIn(['accounts', accountId, 'suspended'], false),
  };
};

const RemoteHint = ({ url }) => (
  <TimelineHint url={url} resource={<FormattedMessage id='timeline_hint.resources.statuses' defaultMessage='Older toots' />} />
);

RemoteHint.propTypes = {
  url: PropTypes.string.isRequired,
};

export default @connect(mapStateToProps)
class AccountTimeline extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list,
    featuredStatusIds: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    withReplies: PropTypes.bool,
    isAccount: PropTypes.bool,
    suspended: PropTypes.bool,
    remote: PropTypes.bool,
    remoteUrl: PropTypes.string,
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

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  handleLoadMore = maxId => {
    this.props.dispatch(expandAccountTimeline(this.props.params.accountId, { maxId, withReplies: this.props.withReplies }));
  }

  setRef = c => {
    this.column = c;
  }

  render () {
    const { statusIds, featuredStatusIds, isLoading, hasMore, suspended, isAccount, multiColumn, remote, remoteUrl } = this.props;

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

    let emptyMessage;

    if (suspended) {
      emptyMessage = <FormattedMessage id='empty_column.account_suspended' defaultMessage='Account suspended' />;
    } else if (remote && statusIds.isEmpty()) {
      emptyMessage = <RemoteHint url={remoteUrl} />;
    } else {
      emptyMessage = <FormattedMessage id='empty_column.account_timeline' defaultMessage='No toots here!' />;
    }

    const remoteMessage = remote ? <RemoteHint url={remoteUrl} /> : null;

    return (
      <Column ref={this.setRef} name='account'>
        <ProfileColumnHeader onClick={this.handleHeaderClick} multiColumn={multiColumn} />

        <StatusList
          prepend={<HeaderContainer accountId={this.props.params.accountId} />}
          alwaysPrepend
          append={remoteMessage}
          scrollKey='account_timeline'
          statusIds={suspended ? emptyList : statusIds}
          featuredStatusIds={featuredStatusIds}
          isLoading={isLoading}
          hasMore={hasMore}
          onLoadMore={this.handleLoadMore}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
          timelineId='account'
        />
      </Column>
    );
  }

}
