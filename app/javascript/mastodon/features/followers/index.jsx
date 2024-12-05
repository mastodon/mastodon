import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { debounce } from 'lodash';

import { TimelineHint } from 'mastodon/components/timeline_hint';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';
import { normalizeForLookup } from 'mastodon/reducers/accounts_map';
import { getAccountHidden } from 'mastodon/selectors';
import { useAppSelector } from 'mastodon/store';

import {
  lookupAccount,
  fetchAccount,
  fetchFollowers,
  expandFollowers,
} from '../../actions/accounts';
import { ColumnBackButton } from '../../components/column_back_button';
import { LoadingIndicator } from '../../components/loading_indicator';
import ScrollableList from '../../components/scrollable_list';
import AccountContainer from '../../containers/account_container';
import { LimitedAccountHint } from '../account_timeline/components/limited_account_hint';
import HeaderContainer from '../account_timeline/containers/header_container';
import Column from '../ui/components/column';

const mapStateToProps = (state, { params: { acct, id } }) => {
  const accountId = id || state.getIn(['accounts_map', normalizeForLookup(acct)]);

  if (!accountId) {
    return {
      isLoading: true,
    };
  }

  return {
    accountId,
    remote: !!(state.getIn(['accounts', accountId, 'acct']) !== state.getIn(['accounts', accountId, 'username'])),
    remoteUrl: state.getIn(['accounts', accountId, 'url']),
    isAccount: !!state.getIn(['accounts', accountId]),
    accountIds: state.getIn(['user_lists', 'followers', accountId, 'items']),
    hasMore: !!state.getIn(['user_lists', 'followers', accountId, 'next']),
    isLoading: state.getIn(['user_lists', 'followers', accountId, 'isLoading'], true),
    suspended: state.getIn(['accounts', accountId, 'suspended'], false),
    hideCollections: state.getIn(['accounts', accountId, 'hide_collections'], false),
    hidden: getAccountHidden(state, accountId),
    blockedBy: state.getIn(['relationships', accountId, 'blocked_by'], false),
  };
};

const RemoteHint = ({ accountId, url }) => {
  const acct = useAppSelector(state => state.accounts.get(accountId)?.acct);
  const domain = acct ? acct.split('@')[1] : undefined;

  return (
    <TimelineHint
      url={url}
      message={<FormattedMessage id='hints.profiles.followers_may_be_missing' defaultMessage='Followers for this profile may be missing.' />}
      label={<FormattedMessage id='hints.profiles.see_more_followers' defaultMessage='See more followers on {domain}' values={{ domain: <strong>{domain}</strong> }} />}
    />
  );
};

RemoteHint.propTypes = {
  url: PropTypes.string.isRequired,
  accountId: PropTypes.string.isRequired,
};

class Followers extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.shape({
      acct: PropTypes.string,
      id: PropTypes.string,
    }).isRequired,
    accountId: PropTypes.string,
    dispatch: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
    blockedBy: PropTypes.bool,
    isAccount: PropTypes.bool,
    suspended: PropTypes.bool,
    hidden: PropTypes.bool,
    remote: PropTypes.bool,
    remoteUrl: PropTypes.string,
    multiColumn: PropTypes.bool,
  };

  _load () {
    const { accountId, isAccount, dispatch } = this.props;

    if (!isAccount) dispatch(fetchAccount(accountId));
    dispatch(fetchFollowers(accountId));
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
    const { params: { acct }, accountId, dispatch } = this.props;

    if (prevProps.accountId !== accountId && accountId) {
      this._load();
    } else if (prevProps.params.acct !== acct) {
      dispatch(lookupAccount(acct));
    }
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandFollowers(this.props.accountId));
  }, 300, { leading: true });

  render () {
    const { accountId, accountIds, hasMore, blockedBy, isAccount, multiColumn, isLoading, suspended, hidden, remote, remoteUrl, hideCollections } = this.props;

    if (!isAccount) {
      return (
        <BundleColumnError multiColumn={multiColumn} errorType='routing' />
      );
    }

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    let emptyMessage;

    const forceEmptyState = blockedBy || suspended || hidden;

    if (suspended) {
      emptyMessage = <FormattedMessage id='empty_column.account_suspended' defaultMessage='Account suspended' />;
    } else if (hidden) {
      emptyMessage = <LimitedAccountHint accountId={accountId} />;
    } else if (blockedBy) {
      emptyMessage = <FormattedMessage id='empty_column.account_unavailable' defaultMessage='Profile unavailable' />;
    } else if (hideCollections && accountIds.isEmpty()) {
      emptyMessage = <FormattedMessage id='empty_column.account_hides_collections' defaultMessage='This user has chosen to not make this information available' />;
    } else if (remote && accountIds.isEmpty()) {
      emptyMessage = <RemoteHint accountId={accountId} url={remoteUrl} />;
    } else {
      emptyMessage = <FormattedMessage id='account.followers.empty' defaultMessage='No one follows this user yet.' />;
    }

    const remoteMessage = remote ? <RemoteHint accountId={accountId} url={remoteUrl} /> : null;

    return (
      <Column>
        <ColumnBackButton />

        <ScrollableList
          scrollKey='followers'
          hasMore={!forceEmptyState && hasMore}
          isLoading={isLoading}
          onLoadMore={this.handleLoadMore}
          prepend={<HeaderContainer accountId={this.props.accountId} hideTabs />}
          alwaysPrepend
          append={remoteMessage}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        >
          {forceEmptyState ? [] : accountIds.map(id =>
            <AccountContainer key={id} id={id} withNote={false} />,
          )}
        </ScrollableList>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(Followers);
