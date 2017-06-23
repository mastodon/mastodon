import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ReactSwipeable from 'react-swipeable';
import HomeTimeline from '../../home_timeline';
import Notifications from '../../notifications';
import PublicTimeline from '../../public_timeline';
import CommunityTimeline from '../../community_timeline';
import HashtagTimeline from '../../hashtag_timeline';
import Compose from '../../compose';
import { getPreviousLink, getNextLink } from './tabs_bar';

const componentMap = {
  'COMPOSE': Compose,
  'HOME': HomeTimeline,
  'NOTIFICATIONS': Notifications,
  'PUBLIC': PublicTimeline,
  'COMMUNITY': CommunityTimeline,
  'HASHTAG': HashtagTimeline,
};

export default class ColumnsArea extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object.isRequired,
  };

  static propTypes = {
    columns: ImmutablePropTypes.list.isRequired,
    singleColumn: PropTypes.bool,
    children: PropTypes.node,
  };

  handleRightSwipe = () => {
    const previousLink = getPreviousLink(this.context.router.history.location.pathname);

    if (previousLink) {
      this.context.router.history.push(previousLink);
    }
  }

  handleLeftSwipe = () => {
    const previousLink = getNextLink(this.context.router.history.location.pathname);

    if (previousLink) {
      this.context.router.history.push(previousLink);
    }
  };

  render () {
    const { columns, children, singleColumn } = this.props;

    if (singleColumn) {
      return (
        <ReactSwipeable onSwipedLeft={this.handleLeftSwipe} onSwipedRight={this.handleRightSwipe} className='columns-area'>
          {children}
        </ReactSwipeable>
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
