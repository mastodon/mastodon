import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import ReactSwipeable from 'react-swipeable';
import { getPreviousLink, getNextLink } from './tabs_bar';

import BundleContainer from '../containers/bundle_container';
import ColumnLoading from './column_loading';
import BundleColumnError from './bundle_column_error';
import { Compose, Notifications, HomeTimeline, CommunityTimeline, PublicTimeline, HashtagTimeline } from '../../ui/util/async-components';

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

  renderLoading = () => {
    return <ColumnLoading />;
  }

  renderError = (props) => {
    return <BundleColumnError {...props} />;
  }

  render () {
    const { columns, children, singleColumn } = this.props;

    if (singleColumn) {
      return (
        <ReactSwipeable onSwipedLeft={this.handleLeftSwipe} onSwipedRight={this.handleRightSwipe} delta={30} className='columns-area'>
          {children}
        </ReactSwipeable>
      );
    }

    return (
      <div className='columns-area'>
        {columns.map(column => {
          const params = column.get('params', null) === null ? null : column.get('params').toJS();

          return (
            <BundleContainer key={column.get('uuid')} fetchComponent={componentMap[column.get('id')]} loading={this.renderLoading} error={this.renderError}>
              {SpecificComponent => <SpecificComponent columnId={column.get('uuid')} params={params} multiColumn />}
            </BundleContainer>
          );
        })}

        {React.Children.map(children, child => React.cloneElement(child, { multiColumn: true }))}
      </div>
    );
  }

}
