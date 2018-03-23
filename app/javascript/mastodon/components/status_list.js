import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import StatusContainer from '../containers/status_container';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ScrollableList from './scrollable_list';
import { FormattedMessage } from 'react-intl';

export default class StatusList extends ImmutablePureComponent {

  static propTypes = {
    scrollKey: PropTypes.string.isRequired,
    statusIds: ImmutablePropTypes.list.isRequired,
    featuredStatusIds: ImmutablePropTypes.list,
    onLoadMore: PropTypes.func,
    onScrollToTop: PropTypes.func,
    onScroll: PropTypes.func,
    trackScroll: PropTypes.bool,
    shouldUpdateScroll: PropTypes.func,
    isLoading: PropTypes.bool,
    isPartial: PropTypes.bool,
    hasMore: PropTypes.bool,
    prepend: PropTypes.node,
    emptyMessage: PropTypes.node,
  };

  static defaultProps = {
    trackScroll: true,
  };

  handleMoveUp = id => {
    const elementIndex = this.props.statusIds.indexOf(id) - 1;
    this._selectChild(elementIndex);
  }

  handleMoveDown = id => {
    const elementIndex = this.props.statusIds.indexOf(id) + 1;
    this._selectChild(elementIndex);
  }

  _selectChild (index) {
    const element = this.node.node.querySelector(`article:nth-of-type(${index + 1}) .focusable`);

    if (element) {
      element.focus();
    }
  }

  setRef = c => {
    this.node = c;
  }

  render () {
    const { statusIds, featuredStatusIds, ...other }  = this.props;
    const { isLoading, isPartial } = other;

    if (isPartial) {
      return (
        <div className='regeneration-indicator'>
          <div>
            <div className='regeneration-indicator__figure' />

            <div className='regeneration-indicator__label'>
              <FormattedMessage id='regeneration_indicator.label' tagName='strong' defaultMessage='Loading&hellip;' />
              <FormattedMessage id='regeneration_indicator.sublabel' defaultMessage='Your home feed is being prepared!' />
            </div>
          </div>
        </div>
      );
    }

    let scrollableContent = (isLoading || statusIds.size > 0) ? (
      statusIds.map(statusId => (
        <StatusContainer
          key={statusId}
          id={statusId}
          onMoveUp={this.handleMoveUp}
          onMoveDown={this.handleMoveDown}
        />
      ))
    ) : null;

    if (scrollableContent && featuredStatusIds) {
      scrollableContent = featuredStatusIds.map(statusId => (
        <StatusContainer
          key={`f-${statusId}`}
          id={statusId}
          featured
          onMoveUp={this.handleMoveUp}
          onMoveDown={this.handleMoveDown}
        />
      )).concat(scrollableContent);
    }

    return (
      <ScrollableList {...other} ref={this.setRef}>
        {scrollableContent}
      </ScrollableList>
    );
  }

}
