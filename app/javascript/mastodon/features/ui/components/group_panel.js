import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { fetchGroups } from 'mastodon/actions/groups';
import { connect } from 'react-redux';
import { createSelector } from 'reselect';
import { NavLink, withRouter } from 'react-router-dom';
import Icon from 'mastodon/components/icon';

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

export default @withRouter
@connect(mapStateToProps)
class GroupPanel extends ImmutablePureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    groups: ImmutablePropTypes.list,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchGroups());
  }

  render () {
    const { groups } = this.props;

    if (!groups || groups.isEmpty()) {
      return null;
    }

    return (
      <div>
        <hr />

        {groups.map(group => (
          <NavLink key={group.get('id')} className='column-link column-link--transparent' strict to={`/groups/${group.get('id')}`}><Icon className='column-link__icon' id='users' fixedWidth />{group.get('title')}</NavLink>
        ))}
      </div>
    );
  }

}
