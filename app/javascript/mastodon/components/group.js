import React, { Fragment } from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import GroupDisplayName from './group_display_name';
import Permalink from './permalink';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default
class Group extends ImmutablePureComponent {

  static propTypes = {
    group: ImmutablePropTypes.map.isRequired,
    hidden: PropTypes.bool,
  };

  render () {
    const { group, hidden } = this.props;

    if (!group) {
      return <div />;
    }

    if (hidden) {
      return (
        <Fragment>
          {group.get('display_name')}
          {group.get('uri')}
        </Fragment>
      );
    }

    return (
      <div className='account'>
        <div className='account__wrapper'>
          <Permalink key={group.get('id')} className='account__display-name' title={group.get('uri')} href={group.get('url')} to={`/groups/${group.get('id')}`}>
            <div className='account__avatar-wrapper'><Avatar account={group} size={36} /></div>
            <GroupDisplayName group={group} />
          </Permalink>
        </div>
      </div>
    );
  }

}
