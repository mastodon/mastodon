import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import scheduleIdleTask from '../features/ui/util/schedule_idle_task';
import getRectFromEntry from '../features/ui/util/get_rect_from_entry';

export default class IntersectionObserverArticle extends ImmutablePureComponent {

  static propTypes = {
    intersectionObserverWrapper: PropTypes.object.isRequired,
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    index: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    listLength: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    saveHeightKey: PropTypes.string,
    cachedHeight: PropTypes.number,
    onHeightChange: PropTypes.func,
    children: PropTypes.node,
  };

  state = {
    isHidden: false, // set to true in requestIdleCallback to trigger un-render
  }

  shouldComponentUpdate (nextProps, nextState) {
    if (!nextState.isIntersecting && nextState.isHidden) {
      // It's only if we're not intersecting (i.e. offscreen) and isHidden is true
      // that either "isIntersecting" or "isHidden" matter, and then they're
      // the only things that matter (and updated ARIA attributes).
      return this.state.isIntersecting || !this.state.isHidden || nextProps.listLength !== this.props.listLength;
    } else if (nextState.isIntersecting && !this.state.isIntersecting) {
      // If we're going from a non-intersecting state to an intersecting state,
      // (i.e. offscreen to onscreen), then we definitely need to re-render
      return true;
    }
    // Otherwise, diff based on "updateOnProps" and "updateOnStates"
    return super.shouldComponentUpdate(nextProps, nextState);
  }

  componentDidMount () {
    const { intersectionObserverWrapper, id } = this.props;

    intersectionObserverWrapper.observe(
      id,
      this.node,
      this.handleIntersection
    );

    this.componentMounted = true;
  }

  componentWillUnmount () {
    const { intersectionObserverWrapper, id } = this.props;
    intersectionObserverWrapper.unobserve(id, this.node);

    this.componentMounted = false;
  }

  handleIntersection = (entry) => {
    const { onHeightChange, saveHeightKey, id } = this.props;

    if (this.node && this.node.children.length !== 0) {
      // save the height of the fully-rendered element
      this.height = getRectFromEntry(entry).height;

      if (onHeightChange && saveHeightKey) {
        onHeightChange(saveHeightKey, id, this.height);
      }
    }

    this.setState((prevState) => {
      if (prevState.isIntersecting && !entry.isIntersecting) {
        scheduleIdleTask(this.hideIfNotIntersecting);
      }
      return {
        isIntersecting: entry.isIntersecting,
        isHidden: false,
      };
    });
  }

  hideIfNotIntersecting = () => {
    if (!this.componentMounted) {
      return;
    }

    // When the browser gets a chance, test if we're still not intersecting,
    // and if so, set our isHidden to true to trigger an unrender. The point of
    // this is to save DOM nodes and avoid using up too much memory.
    // See: https://github.com/tootsuite/mastodon/issues/2900
    this.setState((prevState) => ({ isHidden: !prevState.isIntersecting }));
  }

  handleRef = (node) => {
    this.node = node;
  }

  render () {
    const { children, id, index, listLength, cachedHeight } = this.props;
    const { isIntersecting, isHidden } = this.state;

    if (!isIntersecting && (isHidden || cachedHeight)) {
      return (
        <article
          ref={this.handleRef}
          aria-posinset={index}
          aria-setsize={listLength}
          style={{ height: `${this.height || cachedHeight}px`, opacity: 0, overflow: 'hidden' }}
          data-id={id}
          tabIndex='0'
        >
          {children && React.cloneElement(children, { hidden: true })}
        </article>
      );
    }

    return (
      <article ref={this.handleRef} aria-posinset={index} aria-setsize={listLength} data-id={id} tabIndex='0'>
        {children && React.cloneElement(children, { hidden: false })}
      </article>
    );
  }

}
