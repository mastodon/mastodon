import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import { ScrollContainer } from 'react-router-scroll-4';
import Column from '../ui/components/column';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import AccountAuthorizeContainer from './containers/account_authorize_container';
import { fetchFollowRequests, expandFollowRequests } from '../../actions/accounts';

const messages = defineMessages({
  heading: { id: 'column.follow_requests', defaultMessage: 'Follow requests' },
});

const mapStateToProps = state => ({
  accountIds: state.getIn(['user_lists', 'follow_requests', 'items']),
});

@connect(mapStateToProps)
@injectIntl
export default class FollowRequests extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    accountIds: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
  };

  componentWillMount () {
    this.props.dispatch(fetchFollowRequests());
  }

  handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;

    if (scrollTop === scrollHeight - clientHeight) {
      this.props.dispatch(expandFollowRequests());
    }
  }

  render () {
    const { intl, shouldUpdateScroll, accountIds } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column icon='users' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />

        <ScrollContainer scrollKey='follow_requests' shouldUpdateScroll={shouldUpdateScroll}>
          <div className='scrollable' onScroll={this.handleScroll}>
            {accountIds.map(id =>
              <AccountAuthorizeContainer key={id} id={id} />
            )}
          </div>
        </ScrollContainer>
      </Column>
    );
  }

}
