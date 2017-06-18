import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import HomeTimeline from '../../home_timeline';
import Notifications from '../../notifications';
import PublicTimeline from '../../public_timeline';
import CommunityTimeline from '../../community_timeline';
import HashtagTimeline from '../../hashtag_timeline';
import Compose from '../../compose';

const componentMap = {
  'COMPOSE': Compose,
  'HOME': HomeTimeline,
  'NOTIFICATIONS': Notifications,
  'PUBLIC': PublicTimeline,
  'COMMUNITY': CommunityTimeline,
  'HASHTAG': HashtagTimeline,
};

class ColumnsArea extends ImmutablePureComponent {

  static propTypes = {
    columns: ImmutablePropTypes.list.isRequired,
    singleColumn: PropTypes.bool,
    children: PropTypes.node,
  };

  render () {
    const { columns, children, singleColumn } = this.props;

    if (singleColumn) {
      return (
        <div className='columns-area'>
          {children}
        </div>
      );
    }

    return (
      <div className='columns-area'>
        {columns.map(column => {
          const SpecificComponent = componentMap[column.get('id')];
          const params = column.get('params', null) === null ? null : column.get('params').toJS();
          return <SpecificComponent key={column.get('uuid')} columnId={column.get('uuid')} params={params} multiColumn />;
        })}

        {React.Children.map(children, child => React.cloneElement(child, { multiColumn: true }))}
      </div>
    );
  }

}

export default ColumnsArea;
