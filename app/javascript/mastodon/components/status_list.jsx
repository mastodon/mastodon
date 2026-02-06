import PropTypes from 'prop-types';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { debounce } from 'lodash';

import { TIMELINE_GAP, TIMELINE_PINNED_VIEW_ALL, TIMELINE_SUGGESTIONS } from 'mastodon/actions/timelines';
import { RegenerationIndicator } from 'mastodon/components/regeneration_indicator';
import { InlineFollowSuggestions } from 'mastodon/features/home_timeline/components/inline_follow_suggestions';
import { PinnedShowAllButton } from '@/mastodon/features/account_timeline/v2/pinned_statuses';

import { StatusQuoteManager } from '../components/status_quoted';

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
    statusProps: PropTypes.object,
  };

  static defaultProps = {
    trackScroll: true,
  };

  handleLoadOlder = debounce(() => {
    const { statusIds, lastId, onLoadMore } = this.props;
    onLoadMore(lastId || (statusIds.size > 0 ? statusIds.last() : undefined));
  }, 300, { leading: true });

  setRef = c => {
    this.node = c;
  };

  render () {
    const { statusIds, featuredStatusIds, onLoadMore, timelineId, statusProps, ...other }  = this.props;
    const { isLoading, isPartial } = other;

    if (isPartial) {
      return <RegenerationIndicator />;
    }

    let scrollableContent = (isLoading || statusIds.size > 0) ? (
      statusIds.map((statusId, index) => {
        switch(statusId) {
        case TIMELINE_SUGGESTIONS:
          return (
            <InlineFollowSuggestions key={TIMELINE_SUGGESTIONS} />
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
            <StatusQuoteManager
              key={statusId}
              id={statusId}
              contextType={timelineId}
              scrollKey={this.props.scrollKey}
              showThread
              withCounters={this.props.withCounters}
              {...statusProps}
            />
          );
        }
      })
    ) : null;

    if (scrollableContent && featuredStatusIds) {
      scrollableContent = featuredStatusIds.map(statusId => {
        if (statusId === TIMELINE_PINNED_VIEW_ALL) {
          return <PinnedShowAllButton key={TIMELINE_PINNED_VIEW_ALL} />
        }
        return (
          <StatusQuoteManager
            key={`f-${statusId}`}
            id={statusId}
            featured
            contextType={timelineId}
            showThread
            withCounters={this.props.withCounters}
            {...statusProps} />
        );
      }).concat(scrollableContent);
    }

    return (
      <ScrollableList {...other} showLoading={isLoading && statusIds.size === 0} onLoadMore={onLoadMore && this.handleLoadOlder} ref={this.setRef}>
        {scrollableContent}
      </ScrollableList>
    );
  }
}
