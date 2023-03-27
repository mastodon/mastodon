import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { debounce } from 'lodash';
import LoadingIndicator from 'flavours/glitch/components/loading_indicator';
import {
  lookupAccount,
  fetchAccount,
  fetchFollowers,
  expandFollowers,
} from 'flavours/glitch/actions/accounts';
import { FormattedMessage } from 'react-intl';
import AccountContainer from 'flavours/glitch/containers/account_container';
import Column from 'flavours/glitch/features/ui/components/column';
import ProfileColumnHeader from 'flavours/glitch/features/account/components/profile_column_header';
import HeaderContainer from 'flavours/glitch/features/account_timeline/containers/header_container';
import ImmutablePureComponent from 'react-immutable-pure-component';
import MissingIndicator from 'flavours/glitch/components/missing_indicator';
import ScrollableList from 'flavours/glitch/components/scrollable_list';
import TimelineHint from 'flavours/glitch/components/timeline_hint';
import LimitedAccountHint from '../account_timeline/components/limited_account_hint';
import { getAccountHidden } from 'flavours/glitch/selectors';
import { normalizeForLookup } from 'flavours/glitch/reducers/accounts_map';

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
    hidden: getAccountHidden(state, accountId),
  };
};

const RemoteHint = ({ url }) => (
  <TimelineHint url={url} resource={<FormattedMessage id='timeline_hint.resources.followers' defaultMessage='Followers' />} />
);

RemoteHint.propTypes = {
  url: PropTypes.string.isRequired,
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

  setRef = c => {
    this.column = c;
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  render () {
    const { accountId, accountIds, hasMore, isAccount, multiColumn, isLoading, suspended, hidden, remote, remoteUrl } = this.props;

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

    let emptyMessage;

    const forceEmptyState = suspended || hidden;

    if (suspended) {
      emptyMessage = <FormattedMessage id='empty_column.account_suspended' defaultMessage='Account suspended' />;
    } else if (hidden) {
      emptyMessage = <LimitedAccountHint accountId={accountId} />;
    } else if (remote && accountIds.isEmpty()) {
      emptyMessage = <RemoteHint url={remoteUrl} />;
    } else {
      emptyMessage = <FormattedMessage id='account.followers.empty' defaultMessage='No one follows this user yet.' />;
    }

    const remoteMessage = remote ? <RemoteHint url={remoteUrl} /> : null;

    return (
      <Column ref={this.setRef}>
        <ProfileColumnHeader onClick={this.handleHeaderClick} multiColumn={multiColumn} />

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
          {accountIds.map(id =>
            <AccountContainer key={id} id={id} withNote={false} />,
          )}
        </ScrollableList>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(Followers);
