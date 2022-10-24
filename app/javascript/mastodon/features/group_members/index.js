import React from 'react';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { debounce } from 'lodash';
import LoadingIndicator from '../../components/loading_indicator';
import {
  fetchGroup,
  fetchGroupMemberships,
  expandGroupMemberships,
} from 'mastodon/actions/groups';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import MembershipContainer from './containers/membership_container';
import Column from 'mastodon/components/column';
import ColumnHeader from '../../components/column_header';
import ScrollableList from '../../components/scrollable_list';
import MissingIndicator from 'mastodon/components/missing_indicator';
import LoadMore from 'mastodon/components/load_more';

const messages = defineMessages({
  heading: { id: 'column.group_members', defaultMessage: 'Group members' },
  adminSubheading: { id: 'groups.admin_subheading', defaultMessage: 'Group administrators' },
  moderatorSubheading: { id: 'groups.moderator_subheading', defaultMessage: 'Group moderators' },
  userSubheading: { id: 'groups.user_subheading', defaultMessage: 'Users' },
});

const mapStateToProps = (state, { params: { id } }) => {
  return {
    group: state.getIn(['groups', id]),
    relationship: state.getIn(['group_relationships', id]),
    admins: state.getIn(['group_memberships', 'admin', id]),
    moderators: state.getIn(['group_memberships', 'moderator', id]),
    users: state.getIn(['group_memberships', 'user', id]),
  };
};

export default @connect(mapStateToProps)
@injectIntl
class GroupMembers extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.shape({
      id: PropTypes.string,
    }).isRequired,
    dispatch: PropTypes.func.isRequired,
    admins: ImmutablePropTypes.list,
    moderators: ImmutablePropTypes.list,
    users: ImmutablePropTypes.list,
    group: ImmutablePropTypes.map,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  _load () {
    const { params: { id }, group, dispatch } = this.props;

    if (!group) dispatch(fetchGroup(id));
    dispatch(fetchGroupMemberships(id, 'admin'));
    dispatch(fetchGroupMemberships(id, 'moderator'));
    dispatch(fetchGroupMemberships(id, 'user'));
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

  _handleLoadMore = (role) => {
    this.props.dispatch(expandGroupMemberships(this.props.params.id, role));
  };

  handleLoadMoreAdmins = debounce(() => {
    this._handleLoadMore('admin');
  }, 300, { leading: true });

  handleLoadMoreModerators = debounce(() => {
    this._handleLoadMore('moderator');
  }, 300, { leading: true });

  handleLoadMoreUsers = debounce(() => {
    this._handleLoadMore('user');
  }, 300, { leading: true });

  _renderMemberships = (memberships, role, userRole, handler) => {
    const { params: { id }, intl } = this.props;

    return (
      <React.Fragment key={role}>
        <div className='column-subheading group-role-subheading'>
          {intl.formatMessage(messages[`${role}Subheading`])}
        </div>

        {memberships.get('items').map(accountId =>
          <MembershipContainer key={accountId} groupId={id} accountId={accountId} accountRole={role} userRole={userRole} withNote={false} />,
        )}

        {memberships.get('next') && <LoadMore visible={!memberships.get('isLoading')} onClick={handler} />}
      </React.Fragment>
    );
  };

  render () {
    const { params: { id }, admins, moderators, users, group, relationship, multiColumn, intl } = this.props;

    if (!group) {
      return (
        <Column>
          <MissingIndicator />
        </Column>
      );
    }

    if (!admins || !moderators || !users) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const remotePrependMessage = !!group.get('domain') && (
      <div className='follow_requests-unlocked_explanation'>
        <span>
          <FormattedMessage
            id='groups.incomplete_members_explanation'
            defaultMessage='Information on this remote group may be inaccurate.'
          />
          <br />
          <a href={group.get('url') || group.get('uri')} target='_blank' rel='noopener noreferrer'>
            <FormattedMessage id='group.browse_more_on_origin_server' defaultMessage='Browse more on the original server' />
          </a>
        </span>
      </div>
    );

    let emptyMessage = <FormattedMessage id='group.members.empty' defaultMessage='This group has no members yet.' />;

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.heading)}>
        <ColumnHeader
          icon='users'
          title={intl.formatMessage(messages.heading)}
          onClick={this.handleHeaderClick}
          multiColumn={multiColumn}
          showBackButton
        />

        <ScrollableList
          scrollKey={`group_members-${id}`}
          hasMore={false}
          isLoading={admins.get('isLoading') || moderators.get('isLoading') || users.get('isLoading')}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
          prepend={remotePrependMessage}
          alwaysPrepend
        >
          {
            [
              { role: 'admin', memberships: admins, handler: this.handleLoadMoreAdmins },
              { role: 'moderator', memberships: moderators, handler: this.handleLoadMoreModerators },
              { role: 'user', memberships: users, handler: this.handleLoadMoreUsers }
            ].filter(({ memberships }) => !memberships.get('items').isEmpty()).map(({ role, memberships, handler }) =>
              this._renderMemberships(memberships, role, relationship?.get('role'), handler)
            )
          }
        </ScrollableList>
      </Column>
    );
  }

}
