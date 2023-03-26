import React from 'react';
import Toggle from 'react-toggle';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { lookupAccount, fetchAccount } from '../../actions/accounts';
import { expandAccountFeaturedTimeline, expandAccountTimeline } from '../../actions/timelines';
import AccountStatusListContainer from './containers/account_status_list_container';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import HeaderContainer from './containers/header_container';
import ColumnBackButton from '../../components/column_back_button';
import { List as ImmutableList } from 'immutable';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { FormattedMessage } from 'react-intl';
import TimelineHint from 'mastodon/components/timeline_hint';
import { me } from 'mastodon/initial_state';
import { connectTimeline, disconnectTimeline } from 'mastodon/actions/timelines';
import LimitedAccountHint from './components/limited_account_hint';
import { getAccountHidden } from 'mastodon/selectors';
import { fetchFeaturedTags } from '../../actions/featured_tags';
import { normalizeForLookup } from 'mastodon/reducers/accounts_map';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';

const emptyList = ImmutableList();

const mapStateToProps = (state, { params: { acct, id, tagged }, withReplies = false }) => {
  const accountId = id || state.getIn(['accounts_map', normalizeForLookup(acct)]);

  return {
    accountId,
    remote: !!(state.getIn(['accounts', accountId, 'acct']) !== state.getIn(['accounts', accountId, 'username'])),
    remoteUrl: state.getIn(['accounts', accountId, 'url']),
    isAccount: accountId && !!state.getIn(['accounts', accountId]),
    isLoadingAccount: state.getIn(['accounts', `${accountId}:isLoading`], false),
    featuredStatusIds: withReplies ? ImmutableList() : state.getIn(['timelines', `account:${accountId}:pinned${tagged ? `:${tagged}` : ''}`, 'items'], emptyList),
    suspended: state.getIn(['accounts', accountId, 'suspended'], false),
    hidden: getAccountHidden(state, accountId),
    blockedBy: state.getIn(['relationships', accountId, 'blocked_by'], false),
  };
};

const RemoteHint = ({ url }) => (
  <TimelineHint url={url} resource={<FormattedMessage id='timeline_hint.resources.statuses' defaultMessage='Older posts' />} />
);

RemoteHint.propTypes = {
  url: PropTypes.string.isRequired,
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
    featuredStatusIds: ImmutablePropTypes.list,
    withReplies: PropTypes.bool,
    blockedBy: PropTypes.bool,
    isAccount: PropTypes.bool,
    isLoadingAccount: PropTypes.bool,
    suspended: PropTypes.bool,
    hidden: PropTypes.bool,
    remote: PropTypes.bool,
    remoteUrl: PropTypes.string,
    multiColumn: PropTypes.bool,
  };

  state = {
    withReblogs: true,
  };

  setWithReblogs = ({ target }) =>  {
    this.setState({ withReblogs: target.checked });
  };

  _load () {
    const { accountId, withReplies, params: { tagged }, dispatch } = this.props;
    const { withReblogs } = this.state;

    dispatch(fetchAccount(accountId));

    if (!withReplies) {
      dispatch(expandAccountFeaturedTimeline(accountId, { tagged }));
    }

    dispatch(fetchFeaturedTags(accountId));
    dispatch(expandAccountTimeline(accountId, { withReplies, withReblogs, tagged }));

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

  componentDidUpdate (prevProps, prevState) {
    const { params: { acct, tagged }, accountId, withReplies, dispatch } = this.props;
    const { withReblogs } = this.state;

    if (prevProps.accountId !== accountId && accountId) {
      this._load();
    } else if (prevProps.params.acct !== acct) {
      dispatch(lookupAccount(acct));
    } else if (prevProps.params.tagged !== tagged) {
      if (!withReplies) {
        dispatch(expandAccountFeaturedTimeline(accountId, { tagged }));
      }
      dispatch(expandAccountTimeline(accountId, { withReplies, tagged }));
    } else if (prevState.withReplies !== withReblogs) {
      dispatch(expandAccountTimeline(accountId, { withReplies, withReblogs, tagged }));
    }

    if (prevProps.accountId === me && accountId !== me) {
      dispatch(disconnectTimeline(`account:${me}`));
    }
  }

  componentWillUnmount () {
    const { dispatch, accountId } = this.props;

    if (accountId === me) {
      dispatch(disconnectTimeline(`account:${me}`));
    }
  }

  handleLoadMore = maxId => {
    this.props.dispatch(expandAccountTimeline(
      this.props.accountId,
      { maxId, withReplies: this.props.withReplies, withReblogs: this.state.withReblogs, tagged: this.props.params.tagged },
    ));
  };

  render () {
    const { accountId, featuredStatusIds, blockedBy, suspended, isAccount, isLoadingAccount, hidden, multiColumn, remote, remoteUrl, params: { tagged }, withReplies = false } = this.props;
    const { withReblogs } = this.state;

    if (!isAccount) {
      if (accountId === undefined || isLoadingAccount) {
        return (
          <Column>
            <LoadingIndicator />
          </Column>
        );
      } else {
        return (
          <BundleColumnError multiColumn={multiColumn} errorType='routing' />
        );
      }
    }

    let emptyMessage;

    const forceEmptyState = suspended || blockedBy || hidden;

    if (suspended) {
      emptyMessage = <FormattedMessage id='empty_column.account_suspended' defaultMessage='Account suspended' />;
    } else if (hidden) {
      emptyMessage = <LimitedAccountHint accountId={accountId} />;
    } else if (blockedBy) {
      emptyMessage = <FormattedMessage id='empty_column.account_unavailable' defaultMessage='Profile unavailable' />;
    } else if (remote) {
      emptyMessage = <RemoteHint url={remoteUrl} />;
    } else {
      emptyMessage = <FormattedMessage id='empty_column.account_timeline' defaultMessage='No posts found' />;
    }

    const remoteMessage = remote ? <RemoteHint url={remoteUrl} /> : null;

    const prepend = (
      <>
        <HeaderContainer
          accountId={accountId}
          hideTabs={forceEmptyState}
          tagged={tagged}
        />
        {!tagged && (
          <div className='timeline-setting-toggle'>
            <Toggle id='account-timeline-shows-reblog' checked={withReblogs} onChange={this.setWithReblogs} />
            <label htmlFor='account-timeline-shows-reblog' className='setting-toggle__label'>
              <FormattedMessage id='home.column_settings.show_reblogs' defaultMessage='Show boosts' />
            </label>
          </div>
        )}
      </>
    );

    return (
      <Column>
        <ColumnBackButton multiColumn={multiColumn} />

        <AccountStatusListContainer
          accountId={accountId}
          withReplies={withReplies}
          withReblogs={withReblogs}
          tagged={tagged}
          forceEmptyState={forceEmptyState}
          prepend={prepend}
          alwaysPrepend
          append={remoteMessage}
          scrollKey='account_timeline'
          featuredStatusIds={featuredStatusIds}
          onLoadMore={this.handleLoadMore}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
          timelineId='account'
        />
      </Column>
    );
  }

}

export default connect(mapStateToProps)(AccountTimeline);
