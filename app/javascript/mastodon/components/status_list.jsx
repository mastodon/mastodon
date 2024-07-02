import PropTypes from 'prop-types';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { debounce } from 'lodash';

import { TIMELINE_GAP, TIMELINE_SUGGESTIONS } from 'mastodon/actions/timelines';
import RegenerationIndicator from 'mastodon/components/regeneration_indicator';
import { InlineFollowSuggestions } from 'mastodon/features/home_timeline/components/inline_follow_suggestions';

import StatusContainer from '../containers/status_container';

import { LoadGap } from './load_gap';
import ScrollableList from './scrollable_list';

export default class StatusList extends ImmutablePureComponent {

  static propTypes = {
    scrollKey: PropTypes.string.isRequired,
    statusIds: ImmutablePropTypes.list.isRequired,
    featuredStatusIds: ImmutablePropTypes.list,
    onLoadMore: PropTypes.func,
    onScrollToTop: PropTypes.func,
    onScroll: PropTypes.func,
    trackScroll: PropTypes.bool,
    isLoading: PropTypes.bool,
    isPartial: PropTypes.bool,
    hasMore: PropTypes.bool,
    prepend: PropTypes.node,
    emptyMessage: PropTypes.node,
    alwaysPrepend: PropTypes.bool,
    withCounters: PropTypes.bool,
    timelineId: PropTypes.string,
    lastId: PropTypes.string,
    bindToDocument: PropTypes.bool,
  };

  static defaultProps = {
    trackScroll: true,
  };

  getFeaturedStatusCount = () => {
    return this.props.featuredStatusIds ? this.props.featuredStatusIds.size : 0;
  };

  getCurrentStatusIndex = (id, featured) => {
    if (featured) {
      return this.props.featuredStatusIds.indexOf(id);
    } else {
      return this.props.statusIds.indexOf(id) + this.getFeaturedStatusCount();
    }
  };

  handleMoveUp = (id, featured) => {
    const elementIndex = this.getCurrentStatusIndex(id, featured) - 1;
    this._selectChild(elementIndex, true);
  };

  handleMoveDown = (id, featured) => {
    const elementIndex = this.getCurrentStatusIndex(id, featured) + 1;
    this._selectChild(elementIndex, false);
  };

  handleLoadOlder = debounce(() => {
    const { statusIds, lastId, onLoadMore } = this.props;
    onLoadMore(lastId || (statusIds.size > 0 ? statusIds.last() : undefined));
  }, 300, { leading: true });

  _selectChild (index, align_top) {
    const container = this.node.node;
    const element = container.querySelector(`article:nth-of-type(${index + 1}) .focusable`);

    if (element) {
      if (align_top && container.scrollTop > element.offsetTop) {
        element.scrollIntoView(true);
      } else if (!align_top && container.scrollTop + container.clientHeight < element.offsetTop + element.offsetHeight) {
        element.scrollIntoView(false);
      }
      element.focus();
    }
  }

  setRef = c => {
    this.node = c;
  };

  render () {
    const { statusIds, featuredStatusIds, onLoadMore, timelineId, ...other }  = this.props;
    const { isLoading, isPartial } = other;

    if (isPartial) {
      return <RegenerationIndicator />;
    }

    let scrollableContent = (isLoading || statusIds.size > 0) ? (
      statusIds.map((statusId, index) => {
        switch(statusId) {
        case TIMELINE_SUGGESTIONS:
          return (
            <InlineFollowSuggestions
              key='inline-follow-suggestions'
            />
          );
        case TIMELINE_GAP:
          return (
            <LoadGap
              key={'gap:' + statusIds.get(index + 1)}
              disabled={isLoading}
              param={index > 0 ? statusIds.get(index - 1) : null}
              onClick={onLoadMore}
            />
          );
        default:
          return (
            <StatusContainer
              key={statusId}
              id={statusId}
              onMoveUp={this.handleMoveUp}
              onMoveDown={this.handleMoveDown}
              contextType={timelineId}
              scrollKey={this.props.scrollKey}
              showThread
              withCounters={this.props.withCounters}
            />
          );
        }
      })
    ) : null;

    if (scrollableContent && featuredStatusIds) {
      scrollableContent = featuredStatusIds.map(statusId => (
        <StatusContainer
          key={`f-${statusId}`}
          id={statusId}
          featured
          onMoveUp={this.handleMoveUp}
          onMoveDown={this.handleMoveDown}
          contextType={timelineId}
          showThread
          withCounters={this.props.withCounters}
        />
      )).concat(scrollableContent);
    }

    return (
      <ScrollableList {...other} showLoading={isLoading && statusIds.size === 0} onLoadMore={onLoadMore && this.handleLoadOlder} ref={this.setRef}>
        {scrollableContent}
      </ScrollableList>
    );
  }

}
