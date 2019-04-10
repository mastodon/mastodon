import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from 'flavours/glitch/components/loading_indicator';
import {
  fetchAccount,
  fetchFollowing,
  expandFollowing,
} from 'flavours/glitch/actions/accounts';
import { ScrollContainer } from 'react-router-scroll-4';
import AccountContainer from 'flavours/glitch/containers/account_container';
import Column from 'flavours/glitch/features/ui/components/column';
import ProfileColumnHeader from 'flavours/glitch/features/account/components/profile_column_header';
import HeaderContainer from 'flavours/glitch/features/account_timeline/containers/header_container';
import LoadMore from 'flavours/glitch/components/load_more';
import ImmutablePureComponent from 'react-immutable-pure-component';
import MissingIndicator from 'flavours/glitch/components/missing_indicator';

const mapStateToProps = (state, props) => ({
  isAccount: !!state.getIn(['accounts', props.params.accountId]),
  accountIds: state.getIn(['user_lists', 'following', props.params.accountId, 'items']),
  hasMore: !!state.getIn(['user_lists', 'following', props.params.accountId, 'next']),
});

@connect(mapStateToProps)
export default class Following extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
    hasMore: PropTypes.bool,
    isAccount: PropTypes.bool,
  };

  componentWillMount () {
    this.props.dispatch(fetchAccount(this.props.params.accountId));
    this.props.dispatch(fetchFollowing(this.props.params.accountId));
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) {
      this.props.dispatch(fetchAccount(nextProps.params.accountId));
      this.props.dispatch(fetchFollowing(nextProps.params.accountId));
    }
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;

    if (scrollTop === scrollHeight - clientHeight && this.props.hasMore) {
      this.props.dispatch(expandFollowing(this.props.params.accountId));
    }
  }

  handleLoadMore = (e) => {
    e.preventDefault();
    this.props.dispatch(expandFollowing(this.props.params.accountId));
  }

  shouldUpdateScroll = (prevRouterProps, { location }) => {
    if ((((prevRouterProps || {}).location || {}).state || {}).mastodonModalOpen) return false;
    return !(location.state && location.state.mastodonModalOpen);
  }

  setRef = c => {
    this.column = c;
  }

  render () {
    const { accountIds, hasMore, isAccount } = this.props;

    if (!isAccount) {
      return (
        <Column>
          <MissingIndicator />
        </Column>
      );
    }

    let loadMore = null;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    if (hasMore) {
      loadMore = <LoadMore onClick={this.handleLoadMore} />;
    }

    return (
      <Column ref={this.setRef}>
        <ProfileColumnHeader onClick={this.handleHeaderClick} />

        <ScrollContainer scrollKey='following' shouldUpdateScroll={this.shouldUpdateScroll}>
          <div className='scrollable' onScroll={this.handleScroll}>
            <div className='following'>
              <HeaderContainer accountId={this.props.params.accountId} hideTabs />
              {accountIds.map(id => <AccountContainer key={id} id={id} withNote={false} />)}
              {loadMore}
            </div>
          </div>
        </ScrollContainer>
      </Column>
    );
  }

}
