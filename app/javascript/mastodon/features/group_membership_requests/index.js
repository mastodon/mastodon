import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { debounce } from 'lodash';
import LoadingIndicator from 'mastodon/components/loading_indicator';
import Column from 'mastodon/components/column';
import ColumnHeader from '../../components/column_header';
import AccountAuthorizeContainer from './containers/account_authorize_container';
import { fetchGroup, fetchGroupMembershipRequests, expandGroupMembershipRequests } from 'mastodon/actions/groups';
import ScrollableList from 'mastodon/components/scrollable_list';

const messages = defineMessages({
  heading: { id: 'column.group_membership_requests', defaultMessage: 'Group membership requests' },
});

const mapStateToProps = (state, { params: { id } }) => ({
  group: state.getIn(['groups', id]),
  accountIds: state.getIn(['user_lists', 'membership_requests', id, 'items']),
  isLoading: state.getIn(['user_lists', 'membership_requests', id, 'isLoading'], true),
  hasMore: !!state.getIn(['user_lists', 'membership_requests', id, 'next']),
  locked: !!state.getIn(['groups', id, 'locked']),
  domain: state.getIn(['meta', 'domain']),
});

export default @connect(mapStateToProps)
@injectIntl
class GroupMembershipRequests extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.shape({
      id: PropTypes.string,
    }).isRequired,
    group: ImmutablePropTypes.map,
    dispatch: PropTypes.func.isRequired,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
    accountIds: ImmutablePropTypes.list,
    locked: PropTypes.bool,
    domain: PropTypes.string,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  _load () {
    const { params: { id }, isGroup, dispatch } = this.props;

    if (!isGroup) dispatch(fetchGroup(id));
    dispatch(fetchGroupMembershipRequests(id));
  }

  componentDidMount () {
    this._load();
  }

  componentDidUpdate (prevProps) {
    const { params: { id }, dispatch } = this.props;

    if (prevProps.params.id !== id) {
      this._load();
    }
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandGroupMembershipRequests(this.props.params.id));
  }, 300, { leading: true });

  render () {
    const { intl, params: { id }, accountIds, hasMore, multiColumn, locked, domain, isLoading } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.group_membership_requests' defaultMessage="This group doesn't have any pending membership request yet. When it receives one, it will show up here." />;
    const unlockedPrependMessage = locked ? null : (
      <div className='follow_requests-unlocked_explanation'>
        <FormattedMessage
          id='group_membership_requests.unlocked_explanation'
          defaultMessage='Even though this group is not locked, the {domain} staff thought you might want to review membership requests from these accounts manually.'
          values={{ domain: domain }}
        />
      </div>
    );

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.heading)}>
        <ColumnHeader
          icon='user-plus'
          title={intl.formatMessage(messages.heading)}
          onClick={this.handleHeaderClick}
          multiColumn={multiColumn}
          showBackButton
        />

        <ScrollableList
          scrollKey={`group_membership_requests-${id}`}
          onLoadMore={this.handleLoadMore}
          hasMore={hasMore}
          isLoading={isLoading}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
          prepend={unlockedPrependMessage}
        >
          {accountIds.map(id =>
            <AccountAuthorizeContainer groupId={this.props.params.id} key={id} id={id} />,
          )}
        </ScrollableList>
      </Column>
    );
  }

}
