import React from 'react';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import {
  fetchAccount,
  fetchFollowing,
  expandFollowing,
} from '../../actions/accounts';
import { ScrollContainer } from 'react-router-scroll-4';
import AccountContainer from '../../containers/account_container';
import Column from '../ui/components/column';
import HeaderContainer from '../account_timeline/containers/header_container';
import LoadMore from '../../components/load_more';
import ColumnBackButton from '../../components/column_back_button';

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['user_lists', 'following', props.params.accountId, 'items']),
  hasMore: !!state.getIn(['user_lists', 'following', props.params.accountId, 'next']),
});

@connect(mapStateToProps)
export default class Following extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    accountIds: ImmutablePropTypes.list,
    hasMore: PropTypes.bool,
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

  render () {
    const { shouldUpdateScroll, accountIds, hasMore } = this.props;

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
      <Column>
        <ColumnBackButton />

        <ScrollContainer scrollKey='following' shouldUpdateScroll={shouldUpdateScroll}>
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
