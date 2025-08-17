import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import { List as ImmutableList } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';
import { me } from 'mastodon/initial_state';
import { normalizeForLookup } from 'mastodon/reducers/accounts_map';
import { getAccountHidden } from 'mastodon/selectors/accounts';

import { lookupAccount, fetchAccount } from '../../actions/accounts';
import { expandAccountFeaturedTimeline, expandAccountTimeline, connectTimeline, disconnectTimeline } from '../../actions/timelines';
import { ColumnBackButton } from '../../components/column_back_button';
import { LoadingIndicator } from '../../components/loading_indicator';
import StatusList from '../../components/status_list';
import Column from '../ui/components/column';
import { RemoteHint } from 'mastodon/components/remote_hint';

import { AccountHeader } from './components/account_header';
import { LimitedAccountHint } from './components/limited_account_hint';
import { FeaturedCarousel } from '@/mastodon/components/featured_carousel';

const emptyList = ImmutableList();

const mapStateToProps = (state, { params: { acct, id, tagged }, withReplies = false }) => {
  const accountId = id || state.accounts_map[normalizeForLookup(acct)];

  if (accountId === null) {
    return {
      isLoading: false,
      isAccount: false,
      statusIds: emptyList,
    };
  } else if (!accountId) {
    return {
      isLoading: true,
      statusIds: emptyList,
    };
  }

  const path = withReplies ? `${accountId}:with_replies` : `${accountId}${tagged ? `:${tagged}` : ''}`;

  return {
    accountId,
    isAccount: !!state.getIn(['accounts', accountId]),
    statusIds: state.getIn(['timelines', `account:${path}`, 'items'], emptyList),
    isLoading: state.getIn(['timelines', `account:${path}`, 'isLoading']),
    hasMore: state.getIn(['timelines', `account:${path}`, 'hasMore']),
    suspended: state.getIn(['accounts', accountId, 'suspended'], false),
    hidden: getAccountHidden(state, accountId),
    blockedBy: state.getIn(['relationships', accountId, 'blocked_by'], false),
  };
};

class AccountTimeline extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.shape({
      acct: PropTypes.string,
      id: PropTypes.string,
      tagged: PropTypes.string,
    }).isRequired,
    accountId: PropTypes.string,
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    withReplies: PropTypes.bool,
    blockedBy: PropTypes.bool,
    isAccount: PropTypes.bool,
    suspended: PropTypes.bool,
    hidden: PropTypes.bool,
    multiColumn: PropTypes.bool,
  };

  _load () {
    const { accountId, withReplies, params: { tagged }, dispatch } = this.props;

    dispatch(fetchAccount(accountId));

    if (!withReplies) {
      dispatch(expandAccountFeaturedTimeline(accountId, { tagged }));
    }

    dispatch(expandAccountTimeline(accountId, { withReplies, tagged }));

    if (accountId === me) {
      dispatch(connectTimeline(`account:${me}`));
    }
  }

  componentDidMount () {
    const { params: { acct }, accountId, dispatch } = this.props;

    if (accountId) {
      this._load();
    } else {
      dispatch(lookupAccount(acct));
    }
  }

  componentDidUpdate (prevProps) {
    const { params: { acct, tagged }, accountId, withReplies, dispatch } = this.props;

    if (prevProps.accountId !== accountId && accountId) {
      this._load();
    } else if (prevProps.params.acct !== acct) {
      dispatch(lookupAccount(acct));
    } else if (prevProps.params.tagged !== tagged) {
      if (!withReplies) {
        dispatch(expandAccountFeaturedTimeline(accountId, { tagged }));
      }
      dispatch(expandAccountTimeline(accountId, { withReplies, tagged }));
    }

    if (prevProps.accountId === me && accountId !== me) {
      dispatch(disconnectTimeline({ timeline: `account:${me}` }));
    }
  }

  componentWillUnmount () {
    const { dispatch, accountId } = this.props;

    if (accountId === me) {
      dispatch(disconnectTimeline({ timeline: `account:${me}` }));
    }
  }

  handleLoadMore = maxId => {
    this.props.dispatch(expandAccountTimeline(this.props.accountId, { maxId, withReplies: this.props.withReplies, tagged: this.props.params.tagged }));
  };

  render () {
    const { accountId, statusIds, isLoading, hasMore, blockedBy, suspended, isAccount, hidden, multiColumn, remote, remoteUrl, params: { tagged } } = this.props;

    if (isLoading && statusIds.isEmpty()) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    } else if (!isLoading && !isAccount) {
      return (
        <BundleColumnError multiColumn={multiColumn} errorType='routing' />
      );
    }

    let emptyMessage;

    const forceEmptyState = suspended || blockedBy || hidden;

    if (suspended) {
      emptyMessage = <FormattedMessage id='empty_column.account_suspended' defaultMessage='Account suspended' />;
    } else if (hidden) {
      emptyMessage = <LimitedAccountHint accountId={accountId} />;
    } else if (blockedBy) {
      emptyMessage = <FormattedMessage id='empty_column.account_unavailable' defaultMessage='Profile unavailable' />;
    } else if (remote && statusIds.isEmpty()) {
      emptyMessage = <RemoteHint accountId={accountId} url={remoteUrl} />;
    } else {
      emptyMessage = <FormattedMessage id='empty_column.account_timeline' defaultMessage='No posts found' />;
    }

    return (
      <Column>
        <ColumnBackButton />

        <StatusList
          prepend={
            <>
              <AccountHeader accountId={this.props.accountId} hideTabs={forceEmptyState} tagged={tagged} />
              {!forceEmptyState && <FeaturedCarousel accountId={this.props.accountId} tagged={tagged} />}
            </>
        }
          alwaysPrepend
          append={<RemoteHint accountId={accountId} />}
          scrollKey='account_timeline'
          statusIds={forceEmptyState ? emptyList : statusIds}
          isLoading={isLoading}
          hasMore={!forceEmptyState && hasMore}
          onLoadMore={this.handleLoadMore}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
          timelineId='account'
          withCounters
        />
      </Column>
    );
  }

}

export default connect(mapStateToProps)(AccountTimeline);
