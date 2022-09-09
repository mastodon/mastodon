import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from 'mastodon/components/loading_indicator';
import Column from 'mastodon/features/ui/components/column';
import ColumnBackButtonSlim from 'mastodon/components/column_back_button_slim';
import { fetchGroups } from 'mastodon/actions/groups';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ColumnLink from 'mastodon/features/ui/components/column_link';
import ColumnSubheading from 'mastodon/features/ui/components/column_subheading';
import { createSelector } from 'reselect';
import ScrollableList from 'mastodon/components/scrollable_list';

const messages = defineMessages({
  heading: { id: 'column.groups', defaultMessage: 'Groups' },
  subheading: { id: 'groups.subheading', defaultMessage: 'Your groups' },
});

const getOrderedGroups = createSelector([
    state => state.get('groups'),
    state => state.get('group_relationships')
  ], (groups, group_relationships) => {
  if (!groups) {
    return groups;
  }

  return groups.toList().filter(item => !!item && group_relationships.getIn([item.get('id'), 'member'])).sort((a, b) => a.get('title').localeCompare(b.get('title')));
});

const mapStateToProps = state => ({
  groups: getOrderedGroups(state),
});

export default @connect(mapStateToProps)
@injectIntl
class Groups extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    groups: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  componentWillMount () {
    this.props.dispatch(fetchGroups());
  }

  render () {
    const { intl, groups, multiColumn } = this.props;

    if (!groups) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.groups' defaultMessage="You are not in any group yet. When you join one, it will show up here." />;

    return (
      <Column bindToDocument={!multiColumn} icon='users' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />

        <ScrollableList
          scrollKey='groups'
          emptyMessage={emptyMessage}
          prepend={<ColumnSubheading text={intl.formatMessage(messages.subheading)} />}
          bindToDocument={!multiColumn}
        >
          {groups.map(group =>
            <ColumnLink key={group.get('id')} to={`/groups/${group.get('id')}`} icon='users' text={group.get('title')} />,
          )}
        </ScrollableList>
      </Column>
    );
  }

}
