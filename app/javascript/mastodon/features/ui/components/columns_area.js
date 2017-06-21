import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import ReactSwipeable from 'react-swipeable';
import { getPreviousLink, getNextLink } from './tabs_bar';

const componentMap = {
  'COMPOSE': () => import(/* webpackChunkName: "columns/compose" */'../../compose'),
  'HOME': () => import(/* webpackChunkName: "columns/home_timeline" */'../../home_timeline'),
  'NOTIFICATIONS': () => import(/* webpackChunkName: "columns/notifications" */'../../notifications'),
  'PUBLIC': () => import(/* webpackChunkName: "columns/public_timeline" */'../../public_timeline'),
  'COMMUNITY': () => import(/* webpackChunkName: "columns/community_timeline" */'../../community_timeline'),
  'HASHTAG': () => import(/* webpackChunkName: "columns/hashtag_timeline" */'../../hashtag_timeline'),
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

  renderRetry = (props) => {
    return <BundleRefetch {...props} />;
  }

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
          const params = column.get('params', null) === null ? null : column.get('params').toJS();

          return (
            <Bundle load={componentMap[column.get('id')]} retry={this.renderRetry}>
              {SpecificComponent => SpecificComponent ?
                <SpecificComponent key={column.get('uuid')} columnId={column.get('uuid')} params={params} multiColumn /> :
                (
                  <Column>
                    <ColumnHeader icon=' ' title='' multiColumn={false} />
                    <div className='scrollable' />
                  </Column>
                )}
            </Bundle>
          );
        })}

        {React.Children.map(children, child => React.cloneElement(child, { multiColumn: true }))}
      </div>
    );
  }

}
