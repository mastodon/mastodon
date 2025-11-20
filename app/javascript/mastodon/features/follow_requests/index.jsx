import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { debounce } from 'lodash';

import PersonAddIcon from '@/material-icons/400-24px/person_add.svg?react';

import { fetchFollowRequests, expandFollowRequests } from '../../actions/accounts';
import ScrollableList from '../../components/scrollable_list';
import { me } from '../../initial_state';
import Column from '../ui/components/column';

import AccountAuthorizeContainer from './containers/account_authorize_container';

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

  componentDidMount () {
    this.props.dispatch(fetchFollowRequests());
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandFollowRequests());
  }, 300, { leading: true });

  render () {
    const { intl, accountIds, hasMore, multiColumn, locked, domain, isLoading } = this.props;

    const emptyMessage = <FormattedMessage id='empty_column.follow_requests' defaultMessage="You don't have any follow requests yet. When you receive one, it will show up here." />;
    const unlockedPrependMessage = !locked && accountIds.size > 0 && (
      <div className='follow_requests-unlocked_explanation'>
        <FormattedMessage
          id='follow_requests.unlocked_explanation'
          defaultMessage='Even though your account is not locked, the {domain} staff thought you might want to review follow requests from these accounts manually.'
          values={{ domain: domain }}
        />
      </div>
    );

    return (
      <Column bindToDocument={!multiColumn} icon='user-plus' iconComponent={PersonAddIcon} heading={intl.formatMessage(messages.heading)} alwaysShowBackButton>
        <ScrollableList
          scrollKey='follow_requests'
          onLoadMore={this.handleLoadMore}
          hasMore={hasMore}
          isLoading={isLoading}
          showLoading={isLoading && accountIds.size === 0}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
          prepend={unlockedPrependMessage}
        >
          {accountIds.map(id =>
            <AccountAuthorizeContainer key={id} id={id} />,
          )}
        </ScrollableList>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(FollowRequests));
