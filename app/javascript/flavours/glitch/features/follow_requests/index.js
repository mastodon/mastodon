import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { debounce } from 'lodash';
import LoadingIndicator from 'flavours/glitch/components/loading_indicator';
import Column from 'flavours/glitch/features/ui/components/column';
import ColumnBackButtonSlim from 'flavours/glitch/components/column_back_button_slim';
import AccountAuthorizeContainer from './containers/account_authorize_container';
import { fetchFollowRequests, expandFollowRequests } from 'flavours/glitch/actions/accounts';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ScrollableList from 'flavours/glitch/components/scrollable_list';
import { me } from 'flavours/glitch/util/initial_state';

const messages = defineMessages({
  heading: { id: 'column.follow_requests', defaultMessage: 'Follow requests' },
});

const mapStateToProps = state => ({
  accountIds: state.getIn(['user_lists', 'follow_requests', 'items']),
  isLoading: state.getIn(['user_lists', 'follow_requests', 'isLoading'], true),
  hasMore: !!state.getIn(['user_lists', 'follow_requests', 'next']),
  locked: !!state.getIn(['accounts', me, 'locked']),
  domain: state.getIn(['meta', 'domain']),
});

export default @connect(mapStateToProps)
@injectIntl
class FollowRequests extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
    accountIds: ImmutablePropTypes.list,
    locked: PropTypes.bool,
    domain: PropTypes.string,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  componentWillMount () {
    this.props.dispatch(fetchFollowRequests());
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandFollowRequests());
  }, 300, { leading: true });

  render () {
    const { intl, accountIds, hasMore, multiColumn, locked, domain, isLoading } = this.props;

    if (!accountIds) {
      return (
        <Column name='follow-requests'>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.follow_requests' defaultMessage="You don't have any follow requests yet. When you receive one, it will show up here." />;
    const unlockedPrependMessage = locked ? null : (
      <div className='follow_requests-unlocked_explanation'>
        <FormattedMessage
          id='follow_requests.unlocked_explanation'
          defaultMessage='Even though your account is not locked, the {domain} staff thought you might want to review follow requests from these accounts manually.'
          values={{ domain: domain }}
        />
      </div>
    );

    return (
      <Column bindToDocument={!multiColumn} name='follow-requests' icon='user-plus' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />

        <ScrollableList
          scrollKey='follow_requests'
          onLoadMore={this.handleLoadMore}
          hasMore={hasMore}
          isLoading={isLoading}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
          prepend={unlockedPrependMessage}
        >
          {accountIds.map(id =>
            <AccountAuthorizeContainer key={id} id={id} />,
          )}
        </ScrollableList>
      </Column>
    );
  }

}
